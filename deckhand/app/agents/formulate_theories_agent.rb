class FormulateTheoriesAgent < ApplicationAgent
  arguments :question

  def prompt_text
    <<~PROMPT_TEXT
      While formulating an answer to the following question:

      #{question.indent(2)}

      #{context_prompt}

      Based on this information, formulate a list of theories that might help us answer the question.

      #{return_json_array('theories')}
    PROMPT_TEXT
  end

  def run
    parse_json_array(prompt(prompt_text, format: :json).full_response)
  end
end
