module TestGeneration
  # The FindReactTestFileAgent finds the file that is likely to contain a test for a given file
  class FindReactTestFileAgent < CodebaseAgent
    arguments file: nil

    def find_test_prompt(files)
      <<~PROMPT
        Which file is likely to contain a test for #{file}?

        Reply with "none" if there is no such file that is likely to contain a test for #{file} and we should make a new file.

        Choose from these files, or respond with "<none>" (include the angular brackets or it won't work!). Do not give extra explanation, just the name of the file.

        #{files.join("\n").indent(2)}
      PROMPT
    end

    def run
      output, status = run_task("git ls-files")

      raise "Could not list files in repo: #{output}" unless status.success?

      files = output.lines.select { |f| f.match(/\.(js|ts)x?$/) }.map(&:strip)

      response = prompt(find_test_prompt(files)).output

      return nil if response.include?('<none>')

      files.find { |f| response.include?(f) }
    end
  end
end
