module Deckhand::Tasks
  class TryResolveTheory < Task

    attr_accessor :answer, :need_information, :incorrect

    def run
      question = self.question[:main_question]
      theory = self.question[:theory]

      prompt_text = %Q{# Resolving a theory
We are trying to answer the following question:
  
#{question.indent(2)}
  
#{context_prompt}  
  
To bring us closer to answer the question, we have the following theory:

#{theory.indent(2)}

## Task

If there is enough information to give a conclusion on the theory, state the conclusion. Begin your conclusion with
 "Conclusion:". If there is not enough information to give a conclusion, state what information is missing. Begin
your answer with the word "Missing: ". If the theory is incorrect, state why it is incorrect. Begin your answer with "Incorrect: ".

## Answer
}
      resolution = prompt(prompt_text)["message"]["content"].strip
      if resolution =~ /Conclusion:/
        self.answer = resolution.split("Conclusion:",2).last.strip
      elsif resolution =~ /Missing:/
        self.need_information = resolution.split("Missing:",2).last.strip
      elsif resolution =~ /Incorrect:/
        self.incorrect = resolution.split("Incorrect:",2).last.strip
      else
        raise "Invalid resolution: #{resolution}"
      end
      self
    end
  end
  end