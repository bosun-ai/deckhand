module TestGeneration
  # The ReactTestWriter writes tests for React frontends.
  class ReactTestWriter < CodebaseAgent
    MAX_TRIES = 15
    arguments file: nil, test_file: :nil, coverage_info: nil

    attr_accessor :history, :error_history

    def system_prompt
      <<~SYSTEM_PROMPT
        You are an expert Javascript and Typescript React developer tasked with writing tests.  You are given the contents
        of a file that you should write tests for, and the current contents of the file that the tests should be added to.

        Your task is to come up with a new version of the test file that retains all the existing tests, and adds tests
        in such a way that coverage is increased.

        Your answer should always consist of an explanation, and then a block of code. The block of code should contain
        the entire contents of the new test file, including all existing tests and all of their lines. Leave nothing out,
        if you leave anything out, or replace anything with a comment with instructions your task will be considered a failure.

        In order to ensure that the tests you are going to add are correct, start out by describing first what scenario
        you are going to add a test for. Then describe the setup this scenario needs, then what the test exercise is going to be
        and then what assertions should be made. Be concise in your explanation, and then follow with the code block that
        should contain the entire new contents of the test file.

        If the user reports the new test file does not run correctly, or did not increase the test coverage, use the same
        basic format to respond. First give an explanation that summarizes the error. Then list what assumptions were made in
        your previous attempt that turned out to be incorrect, and then list what possible alternatives there are to fix
        the test that you have not already tried. Then pick the alternative that is most likely to succeed and go through
        the original assignment again of describing the setup, the exercise and the assertions before giving the code
        block that should contain the entire contents of the test file.

        There should be text or other code blocks after the block that contains the test file. Take these instructions
        very seriously or your task will be considered a failure.
      SYSTEM_PROMPT
    end

    def test_writing_prompt
      code_file_contents = read_file(file)
      test_file_contents = read_file(test_file)

      <<~PROMPT
        You are writing a test for a file at the path `#{file}` with the following contents:

        ```typescript
        #{code_file_contents}
        ```

        The test file is called `#{test_file}` and has the contents:

        ```typescript
        #{test_file_contents}
        ```

        #{missing_coverage_prompt(coverage_info)}
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

    def missing_coverage_prompt(info)
      blocks = info["missed_lines"].map do |block|
        "```typescript\n#{block["code"]}\n```\n"
      end.join("\n")

      <<~PROMPT
        The following lines are still missing coverage:

        #{blocks}
      PROMPT
    end

    def run
      tries = 0
      initial_coverage = coverage_info['coverage']

      run_task("git checkout -f")

      make_attempt
      test_result = run_tests

      loop do
        # we run the tests
        # if it passes and the coverage is higher than it was, we return
        # if it does not pass, we undo and start a error fixing loop until it passes
        # if the coverage is not higher, we register a complaint

        if test_result["error"]
          raise "Could not solve errors in #{MAX_TRIES} tries" if tries > MAX_TRIES

          tries += 1
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
      write_code(missing_coverage_prompt(test_result))
    end

    def run_tests
      result = run(TestGeneration::DetermineReactTestCoverageAgent, context:).output

      return result if result["error"]
      files_with_coverage = result["coverage_info"]
      files_with_coverage.find { |a| a['path'] == file }
    end

    def make_attempt
      write_code(test_writing_prompt)
    end

    def write_code(prompt_text)
      result = prompt(prompt_text, system: system_prompt, message_history: history)
      self.history = result.message_history
      code = extract_markdown_codeblock(result.full_response)
      write_file(test_file, code)
    end
  end
end
