class CodebaseAgentService < ApplicationRecord
  belongs_to :codebase

  validates :name, presence: true

  def self.agents
    Rails.autoloaders.main.eager_load_namespace(CodebaseAgents) if Rails.env.development?
    CodebaseAgent.descendants
  end

  def agent_class
    if Rails.env.development?
      name.constantize
    else
      agents = CodebaseAgentService.agents
      agents.find { |a| a.name == name } || raise("Could not find agent class #{name}")
    end
  end

  def process_event(event)
    codebase.run_agent(agent_class, "Process event", event:, service: self)
  end
end
