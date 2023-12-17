module TestGeneration
  # The DetermineReactTestCoverageAgent determines what lines of a React codebase are not covered by tests
  class DetermineReactTestCoverageAgent < CodebaseAgent
    def run
      run_coverage_tool
    end

    def run_coverage_tool
      _, result = run_task("npm test -- --coverage --watchAll=false")
      if result.success?
        lcov_file = read_file("coverage/lcov.info")
        return parse_lcov_file(lcov_file)
      end

      raise "Coverage tool failed with exit code #{result.exitstatus}"
    end

    def parse_lcov_file(lcov_file)
      lcov_file.split(/^end_of_record$/).filter_map do |section|
        section.strip!
        next if section.empty?

        lines_found = section.match(/^LF:(.*)$/)[1].to_i
        lines_hit = section.match(/^LH:(.*)$/)[1].to_i
        coverage = lines_hit.to_f / lines_found
        {
          path: section.match(/^SF:(.*)$/)[1],
          coverage: (coverage || 0.0).round(2)
        }.stringify_keys
      end
    end
  end
end
