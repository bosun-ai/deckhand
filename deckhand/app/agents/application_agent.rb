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

  # parent_checkpoint holds the name of the checkpoint that spawned this agent in the parent agent
  attr_accessor :parent_checkpoint

  # if the agent decides to not execute a checkpoint in the current job, it throws RunAgainLater
  class RunAgainLater < StandardError; end

  # if the agent runs an agent that is executed asynchronously, the agent will be resumed when that agent is
  # finished. So this agent run must be cancelled with RunDeferred
  class RunDeferred < StandardError; end

  def initialize(*args, **kwargs)
    @checkpoint_index = 0
    @checkpoints_executed_count = 0
    @parent_checkpoint = kwargs.delete(:parent_checkpoint)
    context = kwargs[:context]
    if context.is_a? Hash
      kwargs[:context] = ApplicationAgent::Context.from_json(context)
    end
    super
  end

  def around_run(*args, **kwargs, &block)
    @checkpoint_index = 0
    @checkpoints_executed_count = 0

    result = nil

    agent_run = self.agent_run ||= AgentRun.create!(**agent_run_initialization_attributes)

    AgentRun.with_advisory_lock("AgentRun##{agent_run.id}") do
      DeckhandTracer.in_span("#{self.class.name}#run") do
        agent_run.reload # so we have the most recent state in case we were waiting for another process holding the lock before us
        if agent_run.error
          agent_run.update! error: nil
        end
        begin
          current_span = OpenTelemetry::Trace.current_span
          current_span.add_attributes(attrs.except(:parent).stringify_keys.transform_values(&:to_json))

          context&.agent_run = agent_run

          if agent_run.parent
            agent_run.parent.events.create!(event_hash: { type: 'run_agent', content: agent_run.id })
          end

          result = block.call(*args, **kwargs)

          agent_run.update!(output: result, error: nil, context:, finished_at: Time.now)
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
          Rails.logger.error "Caught agent error (AgentRun##{agent_run.id}) while running #{self.class.name}:\n#{e.message}" # \n\n#{e.backtrace.join("\n")}"
        end

        next unless parent_agent_run = agent_run.parent

        # Grabbing two locks is a recipe for deadlocks. The reason I believe this is safe is because the parent
        # will never hold the lock on the child, so the child can always grab the lock on the parent. If two
        # children are running at the same time, then they will both try to grab the lock on the parent, but
        # only one will succeed. The other will be queued and will be resumed when the first one is done. It
        # will never wait on another child.

        # Unless of course the child is being synchronously run in the same thread. In which
        # case the lock will just be granted since we're already holding it. And no other children will be
        # allowed to grab the parent lock while we're running because we're holding the lock on the parent.
        AgentRun.with_advisory_lock("AgentRun##{parent_agent_run.id}") do
          agent_run.reload # maybe updates were made to another instance of the agent_run
          parent_agent_run.reload

          # If this run was done asynchronously then returning is not enough, we need to actively modify the parent state
          # TODO: This feels fragile because we're not verifying if the parent state is actually the state that triggered this
          # run. It should be, because states are always done sequentially, but it would be nicer if we would have access to
          # the checkpoint_name of the agent_run that spawned this run and perhaps something that explicitly marks this run
          # as being an async'ed run.

          parent_state = parent_agent_run.get_state(parent_checkpoint)

          if parent_state
            if agent_run.error
              parent_agent_run.transition_to_error!(parent_checkpoint, agent_run.error)
            elsif agent_run.finished?
              Rails.logger.info("Finished run, resuming parent on next task: #{agent_run.parent.name}##{agent_run.parent.id}")
              parent_agent_run.transition_to_completed!(parent_checkpoint, agent_run)
              AgentRunJob.perform_later(agent_run.parent)
            else # if there is a parent state and we've not failed and there is no value available, then we must be async
                # in which case the value will come later
              parent_agent_run.transition_to_waiting!(parent_checkpoint)
            end
          end
        end
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
      Rails.logger.debug "Actually running agent in #{self.class.name}##{agent_run.id} (#{checkpoint_name}): #{args.inspect}"
      block.call(*args, **kwargs.merge(parent_checkpoint: checkpoint_name))
    end

    nested_agent_run = if !result.is_a? AgentRun
      Rails.logger.debug "Trying to convert agent run result: #{result.inspect} into AgentRun during AgentRun##{agent_run.id}"
      AgentRun.new(**result)
    else
      result
    end

    Rails.logger.debug "In AgentRun##{agent_run.id} after checkpoint got AgentRun##{nested_agent_run.id} (done? #{nested_agent_run.finished_at.inspect})"
    if !nested_agent_run.finished?
      self.agent_run.transition_to_waiting!(self.agent_run.state.checkpoint)
      raise RunDeferred
    end

    nested_agent_run
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
  # and return that, or raise RunAgainLater to indicate that it should be ran again at some point or
  # raise RunDeferred if another process will pick this checkpoint up later
  # It is important that `next_checkpoint` will always either return a completed value or raise an error
  # so that the `run` process never continues to the next step unless there is a valid checkpoint value
  def next_checkpoint(name, &block)
    self.checkpoint_index += 1
    self.checkpoint_name = "#{checkpoint_index}-#{name}"

    has_checkpoint = agent_run.has_state?(checkpoint_name)
    checkpoint_state = agent_run.get_state(checkpoint_name)

    descriptor = "#{self.class.name}##{agent_run.id} #{checkpoint_name}"

    # There are multiple things going wrong.
    # - We are sometimes proceeding to the next checkpoint when the first one is not done yet (still on `running`)
    # - We are sometimes dispatching the same checkpoint (agent_run) twice
    if has_checkpoint && checkpoint_state.value_available?
      checkpoint_state.value
    elsif has_checkpoint && checkpoint_state.failed?
      Rails.logger.error "Retrieved error from checkpoint: #{checkpoint_state.error.inspect}"
      raise checkpoint_state.error
    elsif should_execute_checkpoint? && (!has_checkpoint || (!checkpoint_state.async? || checkpoint_state.queued?))
      Rails.logger.debug("Decided to run checkpoint #{descriptor} (#{has_checkpoint}, #{checkpoint_state&.async?}, #{checkpoint_state&.queued?}, #{checkpoint_state&.inspect})")
      if agent_run.started_at.nil?
        agent_run.update! started_at: Time.now
      end
      @checkpoints_executed_count += 1
      result = nil
      begin
        raw_result = block.call
        result = raw_result.as_json # TODO automatic deserialization so we can work with value classes
      rescue => e
        Rails.logger.error("Caught exception #{e.message} while running checkpoint: #{descriptor}")
        agent_run.transition_to_error!(checkpoint_name, e)
        raise e
      end

      Rails.logger.debug("Ran checkpoint #{descriptor}")

      # if it's an agent run, and the return value is not available then this agent run will be continued
      # at a later time
      if name.include?('run_agent') && checkpoint_state&.async? # TODO better way of distinguishing agent_run checkpoints
        ar = AgentRun.new(**result)
        if ar.state && ( ar.state.queued? || ar.state.failed? )
          agent_run.transition_to_waiting!(checkpoint_name)
          Rails.logger.debug("Decided not to run checkpoint #{descriptor}")
          raise RunDeferred
        end
      end

      async_status = checkpoint_state&.async? && 'ready'
      agent_run.transition_to!(checkpoint_name, result, async_status: async_status)
      result
    elsif checkpoint_state&.waiting?
      Rails.logger.debug("Decided not to run checkpoint because it's waiting #{descriptor}")
      raise RunDeferred
    else
      Rails.logger.debug("Decided to run later checkpoint #{descriptor}: (#{has_checkpoint}, #{checkpoint_state&.async?}, #{checkpoint_state&.queued?}, #{checkpoint_state&.inspect})")
      agent_run.transition_to!(checkpoint_name, nil, async_status: 'queued')
      raise RunAgainLater
    end
  end

  private

  def agent_run_initialization_attributes
    {
      name: self.class.name,
      arguments: arguments.except(:context, :parent),
      context: context.as_json,
      parent: parent&.agent_run,
      parent_checkpoint:
    }
  end

  def should_execute_checkpoint?
    # TODO: we need a more sensible way of determining whether we should spawn a new task for an execution
    checkpoints_executed_count < 1
  end
end
