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
      comment = event.dig(:comment, :body)
      add_documentation_based_on_comment(comment) if comment&.strip&.start_with?(ADD_DOCUMENTATION_HEADER)
    end

    def add_documentation_based_on_comment(comment)
      files = comment.split('*')[1..-2].map(&:strip)
      documentation_context = codebase.agent_context('Adding documentation to files')
      run_agent(Codebase::Maintenance::AddDocumentation, files, context: documentation_context)
    end
  end
end
