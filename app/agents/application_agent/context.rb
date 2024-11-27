class ApplicationAgent::Context < AutonomousAgent::Context
  attr_accessor :agent_run_id, :codebase_id

  def self.from_json(ctx)
    ctx.deep_symbolize_keys!
    new(ctx[:assignment], codebase_id: ctx[:codebase_id], history: ctx[:history], agent_run_id: ctx[:agent_run_id])
  end

  def self.as_json(ctx)
    {
      "assignment" => assignment,
      "codebase_id" => codebase_id,
      "history" => history,
      "agent_run_id" => agent_run_id
    }
  end

  def initialize(assignment, codebase: nil, codebase_id: nil, agent_run_id: nil, **kwargs)
    @codebase_id = codebase_id || codebase&.id
    @agent_run_id = agent_run_id
    super(assignment, **kwargs)
  end

  def codebase
    Codebase.find(codebase_id)
  end

  def codebase=(codebase)
    @codebase_id = codebase&.id
  end

  def agent_run
    AgentRun.find(agent_run_id) if agent_run_id
  end

  def agent_run=(agent_run)
    @agent_run_id = agent_run&.id
  end

  def deep_dup
    super.tap do |context|
      context.agent_run = nil
      context.codebase = codebase
    end
  end

  set_callback :add_history, :after do |context|
    # context.agent_run&.update!(context: context)
    # context.agent_run&.events&.create!(event_hash: context.history.last)
  end
end
