class Codebase::FileAnalysis::UndocumentedFiles < Struct.new(:codebase, :event_callback, keyword_init: true)
  include Deckhand::Lm

  def self.run(codebase, &event_callback)
    new(codebase: codebase, event_callback: event_callback)
      .analyze_codebase()
  end

  def analyze_codebase
    tries = 0
    begin
        
      context = codebase.context.split("\n\n").map do |line|
        {
          type: :observation,
          content: line
        }
      end

      root_context = Deckhand::Context.new("Finding undocumented files", history: context, codebase: codebase, event_callback: event_callback)

      extensions = JSON.parse(Deckhand::Tasks::SimpleFormattedQuestion.run("Given the following context:\n\n#{codebase.context}\n\nWhat file extensions are used for files that classes, modules, functions, interfaces and/or types?", example: { "extensions": ["rb", "js"] }.to_json))["extensions"]

      root_context.add_observation("The codebase uses the following file extensions: #{extensions.join(", ")}")

      files = `cd #{codebase.path} && git ls-files`.split("\n").filter do |file|
        extensions.include? file.split(".").last
      end

      files.shuffle!

      undocumented_files = []

      while undocumented_files.length < 5 && files.any?
        relative_path = files.pop
        file = File.join(codebase.path, relative_path)
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

        answer = prompt(question)["message"]["content"]
        root_context.add_observation("Is #{relative_path} underdocumented: #{answer}")

        if answer.strip.downcase.start_with?("yes")
          undocumented_files << relative_path
        end
      end

      undocumented_files
    rescue => e
      Rails.logger.error("Error in Codebase::FileAnalysis::UndocumentedFiles: #{e.message} #{e.backtrace.join("\n")}}")
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