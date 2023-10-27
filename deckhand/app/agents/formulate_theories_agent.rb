class FormulateTheoriesAgent < ApplicationAgent
  arguments :question

  def prompt_text
    <<~PROMPT_TEXT
      # Formulating theories
      While formulating an answer to the following question:

      #{question.indent(2)}

      #{context_prompt}

      Based on this information, we can formulate the following theories that might help us answer the question:

        -
    PROMPT_TEXT
  end

  def run
    prompt(prompt_text).full_response.split(' - ').map(&:strip)
  end
end
