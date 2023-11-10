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
      AgentRunJob.perform_later(agent_run)
    rescue StandardError => e
      current_span = OpenTelemetry::Trace.current_span
      current_span.record_exception(e)
      current_span.status = OpenTelemetry::Trace::Status.error(e.to_s)
      agent_run&.update!(error: e, context:, finished_at: Time.now)
      Rails.logger.error "Caught agent error (AgentRun##{agent_run&.id}) while running #{self.class.name}:\n#{e.message}\n\n#{e.backtrace.join("\n")}"
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
    if !result.is_a? AgentRun
      AgentRun.new(**result)
    else
      result
    end
  end

  def call_function(prompt_response, **_kwargs)
    next_checkpoint("call_function") do
      tool = tools.find { |t| t.name == prompt_response.function_call_name }
      raise ApplicationTool::Error, "No tool found with name #{prompt_response.function_call_name}" unless tool

      args = prompt_response.function_call_args
      unless args.is_a?(Hash)
        raise ApplicationTool::Error,
              "Got invalid function call args object: #{prompt_response.function_call_args.inspect}"
      end

      begin
        tool.run(**args, context:)
      rescue StandardError => e
        err = ApplicationTool::Error.new("Failed to run tool #{tool} with arguments: #{args}: #{e.message}")
        err.set_backtrace(e.backtrace)
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
    # we only want to run the checkpoint if we're 
    elsif should_execute_checkpoint? && (!has_checkpoint || (!checkpoint_state.async? || checkpoint_state.queued?))
      @checkpoints_executed_count += 1
      raw_result = block.call
      result = raw_result.as_json # TODO automatic deserialization so we can work with value classes
      agent_run&.transition_to!(checkpoint_name, result)
      result
    else
      raise RunAgainLater
    end
  end

  private

  def should_execute_checkpoint?
    # TODO: we need a more sensible way of determining whether we should spawn a new task for an execution
    checkpoints_executed_count < 1
  end
end
