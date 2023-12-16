module TestGeneration
  # The DetermineReactTestCoverageAgent determines what lines of a React codebase are not covered by tests
  class DetermineReactTestCoverageAgent < CodebaseAgent
    def run
      run_coverage_tool
    end

    def run_coverage_tool
      _, result = run_task("npm test -- --coverage --watchAll=false")
      return parse_lcov_file("coverage/lcov.info") if result.success?

      raise "Coverage tool failed with exit code #{result.exitstatus}"
    end

    def parse_lcov_file(lcov_file)
      lcov_file_contents = File.read(lcov_file)
      lcov_file_contents.split(/^end_of_record$/).map do |section|
        lines_found = section.match(/^LF:(.*)$/)[1].to_i
        lines_hit = section.match(/^LH:(.*)$/)[1].to_i
        coverage = lines_hit.to_f / lines_found
        {
          path: section.match(/^SF:(.*)$/)[1],
          coverage:
        }.stringify_keys
      end
    end
  end
end
