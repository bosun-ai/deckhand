require 'test_helper'

class TestGenerationAgentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @codebase = Codebase.new(name: "test-#{SecureRandom.hex(8)}", url: Rails.root / 'test' / 'assets' / 'todolist')
    @context = @codebase.agent_context('investigating project')
    @agent = CodebaseAgents::TestGenerationAgent.new(context: @context)
  end

  test 'should run agent' do
    # @agent should receive :run with TestGeneration::DetermineReactTestCoverageAgent, which should return files with coverage
    @agent
      .expects(:run_agent)
      .with(TestGeneration::DetermineReactTestCoverageAgent, "Determine React test coverage", context: @context)
      .returns(stub(output:
        [
          { 'path' => 'src/App.js', 'coverage' => 0.5 },
          { 'path' => 'src/Other.js', 'coverage' => 0.8 }
        ]
      ))

    @agent
      .expects(:run_agent)
      .with(TestGeneration::FindReactTestFileAgent, "Find React test file", file: 'src/App.js', context: @context)
      .returns(stub(output: 'src/App.test.js'))

    @agent
      .expects(:run_agent)
      .with(TestGeneration::ReactTestWriter, "Write React test", file: 'src/App.js', test_file: 'src/App.test.js', context: @context)

    @agent.run
  end
end
