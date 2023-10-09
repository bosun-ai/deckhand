  class AnalyzeFileTool < ApplicationTool
  WINDOW_SIZE = 200
  WINDOW_OVERLAP = 5

  arguments file_path: nil, question: nil

  def self.name
    "analyze_file"
  end

  def self.description
    "Ask a question about a single file"
  end

  def self.usage
    "#{name} <file_path> <question>, for example #{example}"
  end

  def self.arguments_shape
    { "file_path" => "some_path", "question" => "some_question" }
  end

  def self.parameters
    {
      type: :object,
      properties: {
        file_path: {
          type: :string,
          description: "The path to the file to analyze"
        },
        question: {
          type: :string,
          description: "The question this file might hold the answer to"
        }
      },
      required: ["file_path", "question"]
    }
  end

  def self.example
    "#{name} config/database.yml What database is configured?"
  end

  def scan_text(text, window_size: 50, window_overlap: 5, &block)
    position = 0
    lines = text.lines || []
    total = lines.size
    chunk_increment = window_size - window_overlap
    total_chunks = (total / chunk_increment.to_f).ceil
    iteration = 0
    loop do
      iteration += 1
      remaining_chunks = (total_chunks - iteration - 1).clamp(0, total_chunks)
      window = (lines[position..window_size] || []).join("\n")
      if window.nil? || window.empty?
        break yield "", remaining_chunks
      end
      response = yield window, remaining_chunks
      break response if response
      position += chunk_increment
    end
  end

  def run
    # read the file and then pass it into a LLM together with the question
    raise Error.new("Must give a specific file name") if file_path.blank?
    raise Error.new("Must give a question") if question.blank?

    full_file_path = File.join(path_prefix, file_path)

    raise Error.new("Path `#{file_path}` does not exist") if !File.exist?(full_file_path)
    raise Error.new("Path `#{file_path}` is a directory") if File.directory?(full_file_path)

    file = File.read(full_file_path)

    i = 0

    observations = []

    answer = scan_text(file, window_size: WINDOW_SIZE, window_overlap: WINDOW_OVERLAP) do |window, remaining_chunks|
      i += 1
      prompt = <<~ANALYZE_PROMPT 
        # Text analysis
        In this document observations are made about the text in a file and finally an answer is given to a question.

        ## Context

        You are reading the file `#{file_path}`. You are looking at the file in chunks, this is chunk number #{i} and
        there are #{remaining_chunks} chunks left. #{observations.any? ? "You have made the following observations so far:" : ""}

        #{observations.join("\n")}

        ## Assignment
        Respond with one of the following:
        - CONTINUE to continue reading the file
        - OBSERVE <observation> to make an observation 
        - ANSWER Your answer

        You must come up with an answer if there are no chunks remaining. If there is information that could be relevant to
        the final answer you should make an observation.

        ## Chunk

        ```
        #{window}
        ```

        ## Question
        #{question}

        ## Answer
      ANALYZE_PROMPT

      # TODO the chunking doesn't seem to work. When looking at the Gemfile in chunks of 20 lines there are never any
      # observations made and it concludes that there is no test framework. When given a window of 200 lines it works.

      response = prompt(prompt).full_response

      if response =~ /CONTINUE/
        next false
      elsif response =~ /OBSERVE (.*)/
        observations << $1
        next false
      else
        next response
      end
    end
  end
end