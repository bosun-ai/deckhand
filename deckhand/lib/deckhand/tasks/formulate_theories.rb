module Deckhand::Tasks
class FormulateTheories < Task
  include Deckhand::Lm

  def run
    prompt_text = %Q{# Formulating theories
While formulating an answer to the following question:

#{question.indent(2)}

#{context_prompt}

Based on this information, we can formulate the following theories that might help us answer the question:
  -}
    theories = prompt(prompt_text)["message"]["content"].split(" - ").map(&:strip)
    theories
  end
end
end