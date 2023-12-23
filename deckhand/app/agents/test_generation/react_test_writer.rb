module TestGeneration
  # The ReactTestWriter writes tests for React frontends.
  class ReactTestWriter < ApplicationAgent
    arguments file: nil, test_file: :nil, initial_coverage: nil

    attr_accessor :history, :error_history

    def system_prompt
      <<~SYSTEM_PROMPT
        You are an expert Javascript and Typescript React developer tasked with writing tests.  You are given the contents
        of a file that you should write tests for, and the current contents of the file that the tests should be added to.
        Respond with the new contents of the test file, making sure that all the previously existing tests are preserved.
        Respond with only the contents of the new test file, give no explanation or notes outside of comments in the code.
        If the user responds with an error message, respond with the contents of the new test file in which the error has
        been corrected.
      SYSTEM_PROMPT
    end

    def test_writing_prompt
      code_file_contents = File.read(file)
      test_file_contents = File.read(test_file)

      <<~PROMPT
        You are writing a test for a file at the path `#{file}` with the following contents:

        ```typescript
        #{code_file_contents}
        ```

        The test file is called `#{test_file}` and has the contents:

        ```typescript
        #{test_file_contents}
        ```
      PROMPT
    end

    def error_fixing_prompt(error)
      <<~PROMPT
        The unit tests fail with the following error:

        ```
        #{error}
        ```
      PROMPT
    end

    def missing_coverage_prompt(test_result)
      
      <<~PROMPT
        The following lines are still missing coverage:

        #{}
      PROMPT
    end

    def run
      # we make an attempt
      make_attempt
      test_result = run_tests

      loop do
        # we run the tests
        # if it passes and the coverage is higher than it was, we return
        # if it does not pass, we undo and start a error fixing loop until it passes
        # if the coverage is not higher, we register a complaint

        if test_result["error"]
          fix_error(test_result["error"])
        elsif (coverage = test_result["coverage"]) && coverage > initial_coverage
          return true
        else
          fix_coverage(test_result)
        end

        test_result = run_tests
      end
    end

    # fix_error loops
    def fix_error(error)
      write_code(error_fixing_prompt(error))
    end

    def fix_coverage(test_result)

    end

    def run_tests
      result = run(TestGeneration::DetermineReactTestCoverageAgent, "Determine React test coverage", context:)
      return { "error " => result.error } if result.error

      files_with_coverage = result.output

      files_with_coverage.find { |a| a['path'] == file }
    end

    def make_attempt
      write_code(test_writing_prompt)
    end

    def write_code(prompt_text)
      result = prompt(prompt_text, system: system_prompt, message_history: history)
      self.history = result.message_history
      code = parse_markdown_block(result.full_response)
      write_file(test_file, code)
    end
  end
end
