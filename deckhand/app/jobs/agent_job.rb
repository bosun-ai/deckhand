class AgentJob < ApplicationJob
  queue_as :default

  def perform(agent, *args, **kwargs)
    agent.run(*args, **kwargs)
  end
end
