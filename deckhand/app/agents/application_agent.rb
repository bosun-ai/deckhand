class ApplicationAgent < AutonomousAgent
  include ApplicationAgent::Helpers
  include PromptHelpers
  
  # TODO: allow lambdas for default argument values
  arguments context: nil, tools: [AnalyzeFileTool, ListFilesTool]

  # agent_run is a persisted object that contains the state and unique identifier representing the execution of an
  # agent.
  attr_accessor :agent_run

  # during the execution of an agent its state is stored whenever a potentially longer running task is performed
  # whenever this happens it is marked as a checkpoint

  # checkpoint_name holds the name of the checkpoint that is currently being run
  attr_accessor :checkpoint_name

  # checkpoint_index holds the sequence number of the current checkpoint
  attr_accessor :checkpoint_index

  # checkpoints_executed_count holds the amount of checkpoints that have been executed instead of just retrieved
  # from the agent_run state
  attr_accessor :checkpoints_executed_count

  # if the agent decides to not execute a checkpoint in the current job, it throws RunAgainLater
  class RunAgainLater < StandardError; end

  # if the agent runs an agent that is executed asynchronously, the agent will be resumed when that agent is
  # finished. So this agent run must be cancelled with RunDeferred
  class RunDeferred < StandardError; end

  def initialize(*args, **kwargs)
    @checkpoint_index = 0
    @checkpoints_executed_count = 0
    super
  end

  def around_run(*args, **kwargs, &block)
    @checkpoint_index = 0
    @checkpoints_executed_count = 0
    DeckhandTracer.in_span("#{self.class.name}#run") do
      result = nil

      attrs = {
        name: self.class.name,
        arguments: arguments.except(:context, :parent),
        context: context.as_json,
        parent: parent&.agent_run
      }
      self.agent_run ||= AgentRun.create!(**attrs)
      current_span = OpenTelemetry::Trace.current_span
      current_span.add_attributes(attrs.except(:parent).stringify_keys.transform_values(&:to_json))

      context&.agent_run = agent_run

      if agent_run.parent
        agent_run.parent.events.create!(event_hash: { type: 'run_agent', content: agent_run.id })
      end

      result = block.call(*args, **kwargs)

      agent_run&.update!(output: result, context:, finished_at: Time.now)
    rescue RunAgainLater => e
      Rails.logger.info "Running AgentRun #{agent_run&.id} for #{self.class.name} later."
      AgentRunJob.perform_later(agent_run)
    rescue RunDeferred => e
      Rails.logger.info "AgentRun #{agent_run&.id} for #{self.class.name} deferred."
    rescue StandardError => e
      current_span = OpenTelemetry::Trace.current_span
      current_span.record_exception(e)
      current_span.status = OpenTelemetry::Trace::Status.error(e.to_s)
      agent_run&.update!(error: e, context:, finished_at: Time.now)
      Rails.logger.error "Caught agent error (AgentRun##{agent_run&.id}) while running #{self.class.name}:\n#{e.message}" # \n\n#{e.backtrace.join("\n")}"
    end

    # If this run was done asynchronously then returning is not enough, we need to actively modify the parent state
    # TODO: This feels fragile because we're not verifying if the parent state is actually the state that triggered this
    # run. It should be, because states are always done sequentially, but it would be nicer if we would have access to
    # the checkpoint_name of the agent_run that spawned this run and perhaps something that explicitly marks this run
    # as being an async'ed run.
    parent_agent_run = agent_run&.parent
    parent_state = parent_agent_run&.state
    state = agent_run.state

    if parent_state && state
      if state.failed?
        parent_state.failed!(state.error)
        parent_agent_run.save!
      elsif state.value_available?
        Rails.logger.info("Finished run, resuming parent on next task: #{agent_run.parent.name}##{agent_run.parent.id}")
        parent_state.completed!(state.value)
        parent_agent_run.save!
        AgentRunJob.perform_later(agent_run.parent)
      else # if there is a parent state and we've not failed and there is no value available, then we must be async
           # in which case the value will come later
        parent_state.waiting!
        parent_agent_run.save!
      end
    end

    agent_run
  end

  def around_prompt(*args, **kwargs, &block)
    response = next_checkpoint("prompt") do
      result = block.call(*args, **kwargs)
      agent_run && agent_run.events.create!(
        event_hash: {
          type: 'prompt',
          content: { prompt: result.prompt, response: result.full_response }
        }
      )
      result
    end

    if !response.is_a? Deckhand::Lm::PromptResponse
      Deckhand::Lm::PromptResponse.from_json(response)
    else
      response
    end
  end

  def around_run_agent(*args, **kwargs, &block)
    result = next_checkpoint("run_agent") do
      block.call(*args, **kwargs)
    end
    agent_run = if !result.is_a? AgentRun
      AgentRun.new(**result)
    else
      result
    end
  end

  def call_function(prompt_response, **_kwargs)
    next_checkpoint("call_function") do
      Rails.logger.debug("Trying to call method #{prompt_response.function_call_name}")
      tool = tool_classes.find { |t| t.name == prompt_response.function_call_name }
      raise ApplicationTool::Error, "No tool found with name #{prompt_response.function_call_name}" unless tool

      args = prompt_response.function_call_args
      unless args.is_a?(Hash)
        raise ApplicationTool::Error,
              "Got invalid function call args object: #{prompt_response.function_call_args.inspect}"
      end

      Rails.logger.debug("Trying to call function #{prompt_response.function_call_name} with args #{args.inspect}")

      begin
        result = tool.run(**args, context:)
        Rails.logger.debug("Ran function #{prompt_response.function_call_name} and got #{result.inspect}")
        result
      rescue StandardError => e
        err = ApplicationTool::Error.new("Failed to run tool #{tool} with arguments: #{args}: #{e.message}")
        err.set_backtrace(e.backtrace)
        Rails.logger.error("Failed to run tool #{tool} with arguments #{args}: #{e.message}")
        raise err
      end
    end
  end

  # next_checkpoint will either run a block and return its result, fetch a previous result of the block
  # and return that, or raise RunAgainLater to indicate that it should be ran again at some point
  def next_checkpoint(name, &block)
    self.checkpoint_index += 1
    self.checkpoint_name = "#{checkpoint_index}-#{name}"

    has_checkpoint = agent_run&.has_state?(checkpoint_name)
    checkpoint_state = agent_run&.get_state(checkpoint_name)

    if has_checkpoint && checkpoint_state.value_available?
      checkpoint_state.value
    elsif has_checkpoint && checkpoint_state.failed?
      Rails.logger.error "Retrieved error from checkpoint: #{checkpoint_state.error.inspect}"
      raise checkpoint_state.error
    elsif should_execute_checkpoint? && (!has_checkpoint || (!checkpoint_state.async? || checkpoint_state.queued?))
      Rails.logger.debug("Decided to run checkpoint #{self.class.name}##{agent_run&.id} #{checkpoint_name}")
      @checkpoints_executed_count += 1
      result = nil
      begin
        raw_result = block.call
        result = raw_result.as_json # TODO automatic deserialization so we can work with value classes
      rescue => e
        Rails.logger.error("Caught exception #{e.message} while running checkpoint: #{self.class.name}##{agent_run&.id} #{checkpoint_name}")
        agent_run.transition_to_error!(checkpoint_name, e)
        raise e
      end
      
      Rails.logger.debug("Ran checkpoint #{self.class.name}##{agent_run&.id} #{checkpoint_name}")

      # if it's an agent run, and the return value is not available then this agent run will be continued
      # at a later time
      if name =~ /run_agent/ && checkpoint_state&.async? # TODO better way of distinguishing agent_run checkpoints
        ar = AgentRun.new(**result)
        Rails.logger.debug "Checking ar state: #{ar.inspect}"
        if ar.state.nil?
          Rails.logger.error("AgentRun##{ar.id}: #{ar.inspect}\nResult: #{result.inspect}")
          raise "AgentRun state was nil! AgentRun##{ar.id}: #{ar.inspect}"
        end
        if ar.state.queued? || ar.state.failed?
          Rails.logger.debug("Decided not to run checkpoint #{self.class.name}##{agent_run&.id} #{checkpoint_name}")
          raise RunDeferred
        end
      end

      async_status = checkpoint_state&.async? && 'ready'
      agent_run&.transition_to!(checkpoint_name, result, async_status: async_status)
      result
    else
      Rails.logger.debug("Decided to run later checkpoint #{self.class.name}##{agent_run&.id} #{checkpoint_name}")
      agent_run&.transition_to!(checkpoint_name, nil, async_status: 'queued')
      raise RunAgainLater
    end
  end

  private

  def should_execute_checkpoint?
    # TODO: we need a more sensible way of determining whether we should spawn a new task for an execution
    checkpoints_executed_count < 1
  end
end
