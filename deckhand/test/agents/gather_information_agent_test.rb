require 'test_helper'

class ApplicationAgentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  
  setup do
    @codebase = Codebase.new
    @context = ApplicationAgent::Context.new('investigating project', codebase: @codebase)
    @context.add_observation('There is a file with the name `README.md`')
    @agent = GatherInformationAgent.new('What is this project about?', context: @context)
  end
  
  test 'it makes a prompt and runs an agent' do
    # TODO this style of mocking is silly
    result_mock = Deckhand::Lm::PromptResponse.new({
      "choices" => [
        {
          "message" => {
            "content" => "What does the README say?",
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

    Deckhand::Lm.expects(:prompt).never
    SimplyUseToolAgent.expects(:run).returns(AgentRun.new(output: 'It says good things about you'))
    result = result.resume
    
    assert_nil result.error
    assert_equal "[\"It says good things about you\"]", result.output
  end
end