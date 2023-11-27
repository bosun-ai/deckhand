class CodebaseAgent < ApplicationAgent
  arguments event: nil, service: nil

  def agent_run_initialization_attributes
    super.merge(
      codebase_agent_service_id: service.id
    )
  end
end
