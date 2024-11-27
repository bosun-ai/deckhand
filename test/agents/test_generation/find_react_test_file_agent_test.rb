require 'test_helper'

module TestGeneration
  class FindReactTestFileAgentTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @codebase = Codebase.new(name: "test-#{SecureRandom.hex(8)}", url: Rails.root / 'test' / 'assets' / 'todolist')
      @context = @codebase.agent_context('investigating project')
    end

    EXAMPLE_FILES = <<~FILES.freeze
      src/AddItem.test.tsx
      src/App.test.tsx
      README.md
    FILES

    test 'should run agent' do
      @agent = TestGeneration::FindReactTestFileAgent.new(file: 'src/AddItem.tsx', context: @context)
      @agent.expects(:run_task).with("git ls-files").returns([EXAMPLE_FILES, nil, stub(success?: true)])
      @agent.expects(:prompt).with do |prompt|
        assert prompt.include?('src/AddItem.tsx')
        assert prompt.include?('src/AddItem.test.tsx')
        assert prompt.include?('src/App.test.tsx')
        assert_not prompt.include?('README.md')
      end.returns(stub(full_response: 'src/AddItem.test.tsx'))

      assert_equal 'src/AddItem.test.tsx', @agent.run.output
    end
  end
end
