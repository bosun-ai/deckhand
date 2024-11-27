module TestGeneration
  # The DetermineReactTestCoverageAgent determines what lines of a React codebase are not covered by tests
  class DetermineReactTestCoverageAgent < CodebaseAgent
    def run
      run_coverage_tool
    end

    def run_coverage_tool
      output, error, result = run_task("npm test -- --coverage --watchAll=false --bail=1 --maxConcurrency=1 --maxWorkers=1 -u")

      lcov_file = read_file("coverage/lcov.info")
      coverage_info = parse_lcov_file(lcov_file)

      {
        "error" => result.success? ? nil : format_error(error),
        "coverage_info" => coverage_info
      }
    end

    def format_error(error)
      # filter out lines that are in the node_modules directory
      error.lines.filter_map do |line|
        next if line.include?("node_modules")

        line
      end.join("\n")
    end

    def parse_lcov_file(lcov_file)
      lcov_file.split(/^end_of_record$/).filter_map do |section|
        section.strip!
        next if section.empty?

        lines_found = section.match(/^LF:(.*)$/)[1].to_i
        lines_hit = section.match(/^LH:(.*)$/)[1].to_i

        coverage = lines_found > 0 ? lines_hit.to_f / lines_found : 1.0

        {
          path: section.match(/^SF:(.*)$/)[1],
          coverage: coverage.round(2),
          missed_lines: lines_missing_coverage(section)
        }.stringify_keys
      end
    end

    # returns an array of blocks of lines that are missing coverage
    def lines_missing_coverage(lcov_section)
      path = lcov_section.match(/^SF:(.*)$/)[1]
      file = read_file(path)
      
      lines = lcov_section.split("\n").filter_map do |line|
        next unless line.start_with?("DA:")

        line_number = line.match(/^DA:(\d+),/)[1].to_i
        next if line.match(/^DA:\d+,0$/)

        line_number
      end

      lines.sort!
      current_block = []
      blocks = [current_block]

      lines.each do |line|
        if current_block.empty? || line == current_block.last + 1
          current_block << line
        else
          blocks << current_block = [line]
        end
      end

      file_lines = file.lines
      blocks.reject(&:empty?).map do |block|
        {
          start: block.first,
          end: block.last,
          code: file_lines[block.first - 1..block.last - 1].join
        }.stringify_keys
      end
    end
  end
end
