module Deckhand::Tasks
  class SimpleFormattedQuestion < Task

    attr_accessor :answer, :format, :example
  
    def self.run(question, format="JSON", example: nil)
      new(question, format, example: example).run
    end

    def initialize(question, format, example: nil)
      @question = question
      @format = format
      @example = example
    end
  
    def run
      format_prompt = %Q{Please answer the following question:

#{question}

Please format your answer as a #{format} document structured exactly like the following example:

`````
#{example}
`````

Formatted answer:

``````
}
      system = "You are an application that reformats answers into #{format} documents. Your answers are always syntactically correct and have no extra information."
      answer = prompt(format_prompt, system: system)["message"]["content"]
      awnswer.split("``````").first.strip
    end
  end
  end