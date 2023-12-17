require 'test_helper'

module TestGeneration
  class DetermineReactTestCoverageAgentTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @codebase = Codebase.new(name: "test-#{SecureRandom.hex(8)}", url: Rails.root / 'test' / 'assets' / 'todolist')
      @context = @codebase.agent_context('investigating project')
      @agent = TestGeneration::DetermineReactTestCoverageAgent.new(context: @context)
    end

    test 'should run agent' do
      # the agent should use run_task to run the coverage tool
      @agent.expects(:run_task).with("npm test -- --coverage --watchAll=false").returns([nil, stub(success?: true)])
      @agent.expects(:read_file).with("coverage/lcov.info").returns(LCOV_EXAMPLE)
      result = @agent.run.output

      assert_equal [
        { "path" => "src/AddItem.tsx", "coverage" => 0.5 },
        { "path" => "src/App.tsx", "coverage" => 0.54 },
        { "path" => "src/Common.ts", "coverage" => nil },
        { "path" => "src/ToDoList.tsx", "coverage" => 1.0 },
        { "path" => "src/index.tsx", "coverage" => 0.0 },
        { "path" => "src/reportWebVitals.ts", "coverage" => 0.0 }
      ], result
    end

    LCOV_EXAMPLE = <<~LCOV.freeze
      TN:
      SF:src/AddItem.tsx
      FN:4,(anonymous_0)
      FN:9,(anonymous_1)
      FN:20,(anonymous_2)
      FN:26,(anonymous_3)
      FN:32,(anonymous_4)
      FN:44,(anonymous_5)
      FNF:6
      FNH:2
      FNDA:0,(anonymous_0)
      FNDA:7,(anonymous_1)
      FNDA:0,(anonymous_2)
      FNDA:0,(anonymous_3)
      FNDA:0,(anonymous_4)
      FNDA:7,(anonymous_5)
      DA:4,2
      DA:5,0
      DA:10,7
      DA:11,7
      DA:15,7
      DA:16,7
      DA:17,7
      DA:21,0
      DA:27,0
      DA:33,0
      DA:34,0
      DA:35,0
      DA:38,0
      DA:45,7
      LF:14
      LH:7
      BRDA:5,0,0,0
      BRDA:5,0,1,0
      BRDA:34,1,0,0
      BRDA:34,1,1,0
      BRF:4
      BRH:0
      end_of_record
      TN:
      SF:src/App.tsx
      FN:20,(anonymous_0)
      FN:21,(anonymous_1)
      FN:25,(anonymous_2)
      FN:33,(anonymous_3)
      FN:45,(anonymous_4)
      FNF:5
      FNH:2
      FNDA:0,(anonymous_0)
      FNDA:0,(anonymous_1)
      FNDA:6,(anonymous_2)
      FNDA:0,(anonymous_3)
      FNDA:6,(anonymous_4)
      DA:5,1
      DA:20,1
      DA:21,0
      DA:26,6
      DA:27,6
      DA:30,6
      DA:34,0
      DA:36,0
      DA:37,0
      DA:38,0
      DA:40,0
      DA:46,6
      DA:47,6
      LF:13
      LH:7
      BRDA:36,0,0,0
      BRDA:36,0,1,0
      BRF:2
      BRH:0
      end_of_record
      TN:
      SF:src/Common.ts
      FNF:0
      FNH:0
      LF:0
      LH:0
      BRF:0
      BRH:0
      end_of_record
      TN:
      SF:src/ToDoList.tsx
      FN:8,(anonymous_0)
      FN:22,(anonymous_1)
      FN:38,(anonymous_2)
      FN:53,(anonymous_3)
      FN:54,(anonymous_4)
      FNF:5
      FNH:5
      FNDA:7,(anonymous_0)
      FNDA:8,(anonymous_1)
      FNDA:19,(anonymous_2)
      FNDA:7,(anonymous_3)
      FNDA:12,(anonymous_4)
      DA:8,2
      DA:9,7
      DA:23,8
      DA:25,8
      DA:26,1
      DA:28,7
      DA:29,7
      DA:39,19
      DA:53,2
      DA:54,12
      LF:10
      LH:10
      BRDA:25,0,0,1
      BRDA:25,0,1,7
      BRDA:41,1,0,13
      BRDA:41,1,1,6
      BRF:4
      BRH:4
      end_of_record
      TN:
      SF:src/index.tsx
      FNF:0
      FNH:0
      DA:7,0
      DA:17,0
      LF:2
      LH:0
      BRF:0
      BRH:0
      end_of_record
      TN:
      SF:src/reportWebVitals.ts
      FN:3,(anonymous_0)
      FN:5,(anonymous_1)
      FNF:2
      FNH:0
      FNDA:0,(anonymous_0)
      FNDA:0,(anonymous_1)
      DA:3,0
      DA:4,0
      DA:5,0
      DA:6,0
      DA:7,0
      DA:8,0
      DA:9,0
      DA:10,0
      LF:8
      LH:0
      BRDA:4,0,0,0
      BRDA:4,0,1,0
      BRDA:4,1,0,0
      BRDA:4,1,1,0
      BRF:4
      BRH:0
      end_of_record
    LCOV
  end
end
