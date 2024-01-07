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
      parent_id: SecureRandom.uuid,
      codebase_agent_service_id: @service.id,
    }

    post agent_runs_url, params: { agent_run: agent_run }, as: :json

    assert_response :success

    created_agent_run = AgentRun.find_by(id: agent_run[:id])

    assert created_agent_run.present?
    assert_equal agent_run[:name], created_agent_run.name
    assert_equal agent_run[:arguments], created_agent_run.arguments.symbolize_keys
    assert_equal agent_run[:codebase_agent_service_id], created_agent_run.codebase_agent_service_id
    assert_equal agent_run[:parent_id], created_agent_run.parent_id

    # then send some agent run events

    start_time = AgentRunEvent.timestamp(Time.now)

    agent_run_events = {
      agent_run_id: agent_run[:id],
      events: [
        {
          id: SecureRandom.uuid,
          started_at: start_time,
          duration: 5,
          type: "saw_something",
          content: {
            a: 'b'
          },
          parent_event_id: SecureRandom.uuid,
        }
      ]
    }

    agent_run_event = agent_run_events[:events][0]

    post agent_run_events_url, params: agent_run_events, as: :json

    assert_response :success

    created_agent_run_event = AgentRunEvent.find_by(id: agent_run_event[:id])

    assert created_agent_run_event.present?
    assert_equal agent_run_event[:type], created_agent_run_event.type
    assert_equal agent_run_event[:content], created_agent_run_event.content.symbolize_keys
    assert_equal agent_run_event[:started_at], created_agent_run_event.started_at
    assert_equal agent_run_event[:duration], created_agent_run_event.duration
    assert_equal agent_run[:id], created_agent_run_event.agent_run_id
    assert_equal agent_run_event[:parent_event_id], created_agent_run_event.parent_event_id
  end
end
