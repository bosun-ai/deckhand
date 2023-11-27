module CodebaseAgents
  # The TestGenerationAgent writes tests for Codebases
  class DocumentationAgent < CodebaseAgent
    ADD_DOCUMENTATION_HEADER = '## Undocumented files'.freeze

    def system_prompt
      # TODO: this should be a markdown file
    end

    # TODO: this part of the prompt was intended to be used in a chat conversation:
    # If the user responds with an error message, respond with the contents of the new test file in which the error has
    # been corrected.
    # To make this a thing we should make it possible to give chat histories to the prompt method

    def run
      on_service_enabled if event[:type] == 'enabled'

      comment = event.dig(:comment, :body)
      add_documentation_based_on_comment(comment) if comment&.strip&.start_with?(ADD_DOCUMENTATION_HEADER)
    end

    def add_documentation_based_on_comment(comment)
      return unless comment.match?(/[x] Add documentation to these files/)

      files = comment.split('*')[1..-2].map(&:strip)
      documentation_context = codebase.agent_context('Adding documentation to files')
      run_agent(Codebase::Maintenance::AddDocumentation, files, context: documentation_context)
    end

    def discover_undocumented_files
      context = codebase.agent_context('Discovering undocumented files')
      run_agent(FileAnalysis::UndocumentedFilesAgent, context:)
    end

    def on_service_enabled
      discover_undocumented_files
    end
  end
end
