class AgentRunJob < ApplicationJob
  queue_as :default

  def perform(agent_run)
    agent_run.resume
  end
end
