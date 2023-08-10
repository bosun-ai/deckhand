class ApplicationAgent::Context < AutonomousAgent::Context
  attr_accessor :agent_run
  attr_accessor :codebase

  def initialize(assignment, codebase: nil, **kwargs)
    @codebase = codebase
    super(assignment, **kwargs)
  end

  set_callback :add_history, :after do |context|
    context.agent_run.update!(context: context.to_json)
    context.agent_run.events.create!(event_hash: context.history.last)
  end
end