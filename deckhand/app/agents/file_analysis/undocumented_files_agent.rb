class FileAnalysis::UndocumentedFilesAgent < ApplicationAgent
  def file_extensions_prompt
    <<~PROMPT
      Given the following context:

      #{context.summarize_knowledge.indent(2)}
      
      What file extensions are used for files that classes, modules, functions, interfaces and/or types?
    PROMPT
  end

  def run
    tries = 0
    begin
      extensions_result = run(
        SimpleFormattedQuestionAgent,
        file_extensions_prompt,
        example: { "extensions": ["rb", "js"] }.to_json,
        context: context.deep_dup
      )
      extensions = JSON.parse(extensions_result)["extensions"]

      context.add_observation("The codebase uses the following file extensions: #{extensions.join(", ")}")

      files = `cd #{context.codebase.path} && git ls-files`.split("\n").filter do |file|
        extensions.include? file.split(".").last
      end

      files.shuffle!

      undocumented_files = []

      while undocumented_files.length < 5 && files.any?
        relative_path = files.pop
        file = File.join(context.codebase.path, relative_path)
        if !File.exist?(file)
          next
        end
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

        if answer.strip.downcase.start_with?("yes")
          undocumented_files << relative_path
        end
      end

      undocumented_files
    rescue => e
      Rails.logger.error("Error in FileAnalysis::UndocumentedFilesAgent: #{e.message} #{e.backtrace.join("\n")}}")
      tries += 1
      if tries < 3
        puts "Retrying..."
        retry
      else
        raise e
      end
    end
  end
end
