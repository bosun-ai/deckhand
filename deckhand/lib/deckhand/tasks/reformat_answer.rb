module Deckhand::Tasks
  class ReformatAnswer
    include Deckhand::Lm

    attr_accessor :question, :answer, :format, :example

    def initialize(question, answer, format, example: nil)
      @question = question
      @answer = answer
      @format = format
      @example = example
    end

    def self.run(question, answer, format, example: nil)
      new(question, answer, format, example: example).run
    end

    def run
      format_prompt = %Q{When asked the question:

#{question}

You responded with:

#{answer}

Please reformat your answer as a #{format} document. For example:

#{example}

Reformatted answer:
}
      system = "You are an application that reformats answers into #{format} documents. Your answers are always syntactically correct and have no extra information."
      prompt(format_prompt, system: system)["message"]["content"]
    end
  end
end
