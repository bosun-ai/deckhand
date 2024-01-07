class CodebaseAgentService < ApplicationRecord
  belongs_to :codebase

  has_many :agent_runs, dependent: :destroy

  validates :name, presence: true

  after_save :notify_enabled_change, if: :saved_change_to_enabled?

  scope :enabled, -> { where(enabled: true) }

  def self.agents
    Rails.autoloaders.main.eager_load_namespace(CodebaseAgents) if Rails.env.development?
    CodebaseAgent.descendants
  end

  def pretty_name
    name
      .gsub("CodebaseAgents::", "Deckhand::")
      .split("::")
      .map(&:underscore)
      .map(&:humanize)
      .flat_map{|p| p.split(" ")}
      .map(&:capitalize)
      .join(" ")
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
    codebase.run_agent(agent_class, "Process event", event: event.as_json, service_id: id)
  end

  def notify_enabled_change
    if enabled?
      add_issue_comment("Agent #{name} enabled")
      process_event({ 'type' => 'enabled' })
    else
      add_issue_comment("Agent #{name} disabled")
      process_event({ 'type' => 'disabled' })
    end
  end

  def github_issue_id
    codebase.github_app_issue_id
  end

  def add_issue_comment(comment)
    codebase.github_client&.add_comment(codebase.github_repo_name, github_issue_id, comment)
  end
end
