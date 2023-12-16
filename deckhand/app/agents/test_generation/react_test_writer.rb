module TestGeneration
  # The ReactTestWriter writes tests for React frontends.
  class ReactTestWriter < ApplicationAgent
    arguments code_file_path: nil, test_file_path: :nil

    def system_prompt
      <<~SYSTEM_PROMPT
        You are an expert Javascript/Typescript React developer tasked with writing tests.  You are given the contents of
        a file that you should write tests for, and the current contents of the file that the tests should be added to.
        Respond with the new contents of the test file, making sure that all the previously existing tests are preserved.
        Respond with only the contents of the new test file, give no explanation or notes outside of comments in the code.
      SYSTEM_PROMPT
    end

    # TODO: this part of the prompt was intended to be used in a chat conversation:
    # If the user responds with an error message, respond with the contents of the new test file in which the error has
    # been corrected.
    # To make this a thing we should make it possible to give chat histories to the prompt method

    def run
      code_file_contents = File.read(code_file_path)
      test_file_contents = File.read(test_file_path)

      result = prompt(
        <<~PROMPT
          You are writing a test for a file at the path `#{code_file_path}` with the following contents:

          ```typescript
          #{code_file_contents}
          ```

          The test file is called `#{test_file_path}` and has the contents:

          ```typescript
          #{test_file_contents}
          ```
      PROMPT
      ).output

      new_contents = parse_markdown_block(result)
    end
  end
end
