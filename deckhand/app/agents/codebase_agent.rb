class CodebaseAgent < ApplicationAgent
  arguments event: nil, service_id: nil

  def agent_run_initialization_attributes
    super.merge(
      codebase_agent_service_id: service_id
    )
  end

  def service
    @service ||= CodebaseAgentService.find(service_id)
  end

  def add_issue_comment(comment)
    github_client&.add_comment(service.codebase.name, github_issue_id, comment)
  end

  def github_client
    service.codebase.github_client
  end

  def github_issue_id
    service.codebase.github_app_issue_id
  end
end
