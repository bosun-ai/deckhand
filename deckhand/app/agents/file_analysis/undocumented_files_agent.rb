class FileAnalysis::UndocumentedFilesAgent < ApplicationAgent
  def file_extensions_prompt
    <<~PROMPT
      Given the following description of the project:

      #{context.summarize_knowledge.indent(2)}

      Given the programming languages and frameworks mentioned in this project description, what file extensions would
      be used for files that define classes, modules, functions, interfaces and/or types in those languages and
       frameworks?

    PROMPT
  end

  def run
    tries = 0
    files = begin
      extensions_result = run(
        SimpleFormattedQuestionAgent,
        file_extensions_prompt,
        example: { "extensions": %w[rb js] }.to_json,
        context: context.deep_dup
      ).output
      extensions = JSON.parse(extensions_result)["extensions"]

      context.add_observation("The codebase uses the following file extensions: #{extensions.join(', ')}")

      files = `cd #{context.codebase.path} && git ls-files`.split("\n").filter do |file|
        extensions.include? file.split('.').last
      end

      files.shuffle!

      undocumented_files = []

      while undocumented_files.length < 5 && files.any?
        relative_path = files.pop
        file = File.join(context.codebase.path, relative_path)
        next unless File.exist?(file)

        question = <<~PROMPT
          Is this file underdocumented? An underdocumented file is a code file that has public members such as classes,
          functions, or variables that are not preceded by at least one comment. Start your answer with "Yes." if there
          is such a public member, and "No." if there is not.

          File
          -------

          ```
          #{File.read(file)}
          ```

          Answer
          -------
        PROMPT

        answer = prompt(question).full_response
        context.add_observation("Is #{relative_path} underdocumented: #{answer}")

        undocumented_files << relative_path if answer.strip.downcase.start_with?('yes')
      end

      undocumented_files
    rescue StandardError => e
      Rails.logger.error("Error in FileAnalysis::UndocumentedFilesAgent: #{e.message} #{e.backtrace.join("\n")}}")
      tries += 1
      raise e unless tries < 3

      puts 'Retrying...'
      retry
    end

    
    if files&.any?
      markdown = %Q{#{ADD_DOCUMENTATION_HEADER}\n\nFound these undocumented files:\n\n#{files.map { |f| "* #{f}" }.join("\n")}
\n\nIf you would like for Bosun Deckhand to add documentation to these files, check the box below:\n\n- [ ] Add documentation to these files\n\n}
      # html = github_client.markdown(markdown, mode: "gfm", context: name)
      # add_main_issue_comment(html)
      context.codebase.add_main_issue_comment(markdown)
    end
  end
end
