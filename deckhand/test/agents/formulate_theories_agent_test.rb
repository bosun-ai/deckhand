require 'test_helper'

class ApplicationAgentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  
  setup do
    @codebase = Codebase.new
    @context = ApplicationAgent::Context.new('investigating project', codebase: @codebase)
    @context.add_observation('There is a file with the name `README.md`')
    @agent = FormulateTheoriesAgent.new('What is this project about?', context: @context)
  end
  
  test 'it makes a prompt and runs an agent' do
    # TODO this style of mocking is silly
    result_mock = Deckhand::Lm::PromptResponse.new({
      "choices" => [
        {
          "message" => {
            "content" => { "theories" => ["It is a good agent", "It is a bad agent"] }.to_json,
            "role" => "assistant",
            "function_call" => nil
          },
        }
      ]
    }, prompt: "What is this project about?", options: nil)

    Deckhand::Lm.expects(:prompt).returns(result_mock)

    result = @agent.run


    assert_nil result.error
    
    assert_equal ["It is a good agent", "It is a bad agent"], result.output
  end
end