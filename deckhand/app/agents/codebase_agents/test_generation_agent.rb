module CodebaseAgents
  # The TestGenerationAgent writes tests for Codebases
  class TestGenerationAgent < CodebaseAgent
    def system_prompt
      # TODO: this should be a markdown file
    end

    # TODO: this part of the prompt was intended to be used in a chat conversation:
    # If the user responds with an error message, respond with the contents of the new test file in which the error has
    # been corrected.
    # To make this a thing we should make it possible to give chat histories to the prompt method

    # ok so the flow is going to be like this:
    # 1. user activates the agent
    # 2. agent runs the coverage tool, identifies what lines are not covered
    # 3. agent writes a test for the uncovered lines
    # 4. if the test fails, the changes are reverted and the agent is asked to fix the problem
    # 4. agent commits the test to the repo
    # 5. agent runs the coverage tool again, identifies what lines are not covered
    # 6. if there's still uncovered lines, the agent starts a new agent run
    def run
      if event['type'] == 'enabled'
        run_test_generation
      end
    end

    def run_test_generation
      coverage_result = run(TestGeneration::DetermineReactTestCoverageAgent, context:).output

      coverage_info = coverage_result["coverage_info"]
        .select { |a| a['missed_lines'].any? }
        .min_by { |a| a['coverage'] }

      file = coverage_info['path']
      test_file = run(TestGeneration::FindReactTestFileAgent, file:, context:).output

      result = run(TestGeneration::ReactTestWriter, file:, test_file:, coverage_info:, context:).output

      raise "Test generation failed" if result.nil?

      codebase.commit("Add test for #{file}")
    end
  end
end
