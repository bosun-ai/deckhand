class Deckhand::Tools::AnalyzeFile
  WINDOW_SIZE = 200
  WINDOW_OVERLAP = 5

  def self.name
    "analyze_file"
  end

  def self.description
    "Ask a question about a file"
  end

  def self.usage
    "#{name} <file_path> <question>"
  end

  def self.run(*args)
    new(*args).run()
  end

  def initialize(file_path, question)
    @file_path = file_path
    @question = question
  end
  
  def scan_text(text, window_size: 20, window_overlap: 5, &block)
    position = 0
    lines = text.lines
    total = lines.size
    chunk_increment = window_size - window_overlap
    total_chunks = (total - window_size) / chunk_increment
    iteration = 0
    loop do
      iteration += 1
      remaining_chunks = total_chunks - iteration - 1
      window = lines[position..window_size].join("\n")
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
    return "That file does not exist" if !File.exist?(@file_path)

    file = File.read(@file_path)

    i = 0
    
    observations = []

    answer = scan_text(file, window_size: WINDOW_SIZE, window_overlap: WINDOW_OVERLAP) do |window, remaining_chunks|
      i += 1
      prompt = %Q{ 

# Text analysis
In this document observations are made about the text in a file and finally an answer is given to a question.

## Context

You are reading the file `#{@file_path}`. You are looking at the file in chunks, this is chunk number #{i} and
 there are #{remaining_chunks} chunks left. #{ observations.any? ? "You have made the following observations so far:" : "" }

#{observations.join("\n")}

## Assignment
Respond with one of the following:
 - CONTINUE to continue reading the file
 - OBSERVE <observation> to make an observation 
 - ANSWER Your answer

You must come up with an answer if there are no chunks remaining.

## Chunk

```
#{window}
````

## Question
#{@question}

## Answer
}
      # TODO the chunking doesn't seem to work. When looking at the Gemfile in chunks of 20 lines there are never any
      # observations made and it concludes that there is no test framework. When given a window of 200 lines it works.

      # puts "Prompting LLM:\n----\n#{prompt}\n----\n"
      response = Deckhand::Lm.prompt(prompt)["message"]["content"].strip
      # puts "Response from LLM:\n----\n#{response}\n----\n"

      if response =~ /CONTINUE/
        next false
      elsif response =~ /OBSERVE (.*)/
        observations << $1
        puts "Made observation: #{observations.last}"
        next false
      else
        next response 
      end
    end

  end
end