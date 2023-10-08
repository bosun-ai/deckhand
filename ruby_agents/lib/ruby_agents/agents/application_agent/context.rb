class ApplicationAgent::Context < AutonomousAgent::Context
  attr_accessor :agent_run, :codebase_id

  def initialize(assignment, codebase: nil, **kwargs)
    @codebase_id = codebase.id
    super(assignment, **kwargs)
  end

  def codebase
    raise "finding codebase not allowed"
  end

  def codebase=(codebase)
    @codebase_id = codebase.id
  end

  def deep_dup
    super.tap do |context|
      context.agent_run = nil
      context.codebase = codebase
    end
  end

  set_callback :add_history, :after do |context|
    # TODO: should post agent run updates to amqp instead
    AmqpConnection.instance.publish_on_channel("agents.update", context.agent_run.as_json)
    AmqpConnection.instance.publish_on_channel("agents.event", context.agent_run.events.last.as_json)
  end
end

