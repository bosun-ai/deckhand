require "test_helper"

class CodebaseAgentServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @codebase = Codebase.create!(name: 'test', github_app_installation_id: nil, url: 'https://example.com')
    @service = CodebaseAgentService.create!(
      codebase: @codebase, name: CodebaseAgents::TestGenerationAgent.name,
      configuration: { 'something' => 'or other' },
      state: { 'some' => 'state' }
    )
    perform_enqueued_jobs
  end

  test "process_event it runs the agent" do
    @service.process_event({ 'action' => 'opened' })
    assert_enqueued_jobs 1
    assert_enqueued_with(job: AgentJob)
    perform_enqueued_jobs
    assert_performed_jobs 2
  end
end
