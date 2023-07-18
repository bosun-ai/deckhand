module Deckhand::Tasks
  class WriteDocumentation < Task
    def run
      information_questions = prompt(prompt_text)["message"]["content"]
    end
  end
end