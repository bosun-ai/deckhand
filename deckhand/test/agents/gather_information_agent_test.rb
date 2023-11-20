require 'test_helper'

class ApplicationAgentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @codebase = Codebase.new
    @context = ApplicationAgent::Context.new('investigating project', codebase: @codebase)
    @context.add_observation('There is a file with the name `README.md`')
    @agent = GatherInformationAgent.new('What is this project about?', context: @context)
    # @agent.agent_run = AgentRun.create!(context: { history: []}, name: 'GatherInformationAgent', arguments: {}, states: {})
  end

  test 'it makes a prompt and runs an agent' do
    # TODO this style of mocking is silly
    result_mock = Deckhand::Lm::PromptResponse.new(
      {
        "choices" => [
          {
            "message" => {
              "content" => { questions: ["What does the README say?"]}.to_json,
              "role" => "assistant",
              "function_call" => nil
            },
          }
        ]
      }, prompt: "What is this project about?", options: nil)

    Deckhand::Lm.expects(:prompt).returns(result_mock)

    result = @agent.run

    assert_nil result.error
    assert_nil result.finished_at

    assert_enqueued_jobs 1
    result_agent = AgentRun.create!(output: 'It says good things about you', finished_at: Time.now)
    Deckhand::Lm.expects(:prompt).never
    SimplyUseToolAgent
      .expects(:run)
      .with { |q, **_kwargs| q == 'What does the README say?' }
      .returns(result_agent)

    perform_enqueued_jobs
    perform_enqueued_jobs

    assert_enqueued_jobs 0

    result.reload

    assert_nil result.error
    assert_equal ["It says good things about you"], result.output
  end
end
