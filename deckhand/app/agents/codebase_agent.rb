class CodebaseAgent < ApplicationAgent
  arguments event: nil, service_id: nil

  def agent_run_initialization_attributes
    super.merge(
      codebase_agent_service_id: service_id
    )
  end

  def run_agent_child_attributes
    super.merge(
      service_id:
    )
  end

  def run_task(task)
    output = `cd #{service.codebase.path} && #{task}`
    [output, $CHILD_STATUS]
  end

  def read_file(file)
    file.gsub!(%r{^/}, '')
    file.gsub!(%r{^./}, '')
    File.read(Pathname.new(service.codebase.path) / file)
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
