class AgentRun::EventsAggregator
  attr_reader :agent_run
  def initialize(agent_run)
    @agent_run = agent_run
  end

  def aggregate!
    # do a cool thing
  end
end