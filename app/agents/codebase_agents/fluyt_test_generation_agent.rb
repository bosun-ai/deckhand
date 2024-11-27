module CodebaseAgents
  # The TestGenerationAgent writes tests for Codebases
  class FluytTestGenerationAgent < CodebaseAgent
    def run
      if event['type'] == 'enabled'
        run_test_generation
      end
    end

    def run_test_generation
			# TODO notify fluyt
    end
  end
end
