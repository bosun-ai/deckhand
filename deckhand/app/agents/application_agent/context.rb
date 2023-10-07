class ApplicationAgent::Context < AutonomousAgent::Context
  attr_accessor :agent_run, :codebase

  def initialize(assignment, codebase: nil, **kwargs)
    @codebase = codebase
    super(assignment, **kwargs)
  end

  def codebase
    Codebase.find(codebase_id)
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
    context.agent_run.update!(context: context.to_json)
    context.agent_run.events.create!(event_hash: context.history.last)
  end
end
