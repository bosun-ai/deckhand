class ApplicationAgent::Context < AutonomousAgent::Context
  attr_accessor :agent_run

  set_callback :add_history, :after do |context|
    context.agent_run.update!(context: context.to_json)
    context.agent_run.emit_event(context.history.last)
  end
end