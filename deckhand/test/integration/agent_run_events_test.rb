require "test_helper"

class AgentRunEventsTest < ActionDispatch::IntegrationTest
  setup do
    @codebase = Codebase.create!(name: "test", url: './test/assets/todolist')
    @service = CodebaseAgentService.create!(name: "test", codebase: @codebase)
  end

  test "creating an agent run and then sending agent run events" do
    # first create an agent run 
    agent_run = {
      id: SecureRandom.uuid,
      name: "test",
      arguments: {
        a: 'b'
      },
      started_at: Time.now,
      codebase_agent_service_id: @service.id,
    }

    post agent_runs_url, params: { agent_run: agent_run }, as: :json

    assert_response :success

    created_agent_run = AgentRun.find_by(id: agent_run[:id])

    assert created_agent_run.present?
    assert_equal agent_run[:name], created_agent_run.name
    assert_equal agent_run[:arguments], created_agent_run.arguments.symbolize_keys
    assert_equal agent_run[:codebase_agent_service_id], created_agent_run.codebase_agent_service_id

    # then send some agent run events

    start_time = AgentRunEvent.timestamp(Time.now)

    agent_run_event = {
      id: SecureRandom.uuid,
      agent_run_id: agent_run[:id],
      events: [
        {
          started_at: start_time,
          duration: 5,
          type: "saw_something",
          content: {
            a: 'b'
          }
      
        }
      ]
    }

    post agent_run_events_url, params: agent_run_event, as: :json

    assert_response :success

    created_agent_run_event = AgentRunEvent.find_by(agent_run_id: agent_run[:id])

    assert created_agent_run_event.present?
    assert_equal agent_run_event[:events][0][:type], created_agent_run_event.type
    assert_equal agent_run_event[:events][0][:content], created_agent_run_event.content.symbolize_keys
    assert_equal agent_run_event[:events][0][:started_at], created_agent_run_event.started_at
    assert_equal agent_run_event[:events][0][:duration], created_agent_run_event.duration
  end
end
