module Deckhand::Tasks
  class TryRefuteTheory < Task

    attr_accessor :correct, :incorrect

    def run
      question = self.question[:main_question]
      theory = self.question[:theory]

      prompt_text = %Q{# Refuting a theory
We are trying to answer the following question:
  
#{question.indent(2)}
  
#{context_prompt}  
  
To bring us closer to answer the question, we have the following theory:

#{theory.indent(2)}

## Task

If you can refute the theory, state why it is incorrect. Begin your answer with "Incorrect: ". If you can't refute the
 theory, state why it is correct. Begin your answer with "Correct: ".

## Answer
}
      resolution = prompt(prompt_text)["message"]["content"].strip
      if resolution =~ /Correct:/
        self.correct = resolution.split("Correct:",2).last.strip
      elsif resolution =~ /Incorrect:/
        self.incorrect = resolution.split("Incorrect:",2).last.strip
      else
        raise "Invalid resolution: #{resolution}"
      end
      self
    end
  end
  end