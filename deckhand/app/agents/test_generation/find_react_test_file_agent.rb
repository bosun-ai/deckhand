module TestGeneration
  # The FindReactTestFileAgent finds the file that is likely to contain a test for a given file
  class FindReactTestFileAgent < CodebaseAgent
    arguments file: nil

    def run
      files =
        `cd #{context.codebase.path} && git ls-files`
        .split("\n")
        .select { |f| f.match(/\.test\.(js|ts)x?$/) }

      prompt = <<~PROMPT
        Which file is likely to contain a test for #{file}?

        Reply with "none" if there is no such file that is likely to contain a test for #{file} and we should make a new file.

        Choose from these files, or respond with "none". Do not give extra explanation, just the name of the file.

        #{files.join("\n").indent(2)}
      PROMPT

      response = prompt(prompt).output

      return nil if response.include?('none')

      files.find { |f| response.include?(f) }
    end
  end
end
