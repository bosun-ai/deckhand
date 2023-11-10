class FormulateTheoriesAgent < ApplicationAgent
  arguments :question

  def prompt_text
    <<~PROMPT_TEXT
      While formulating an answer to the following question:

      #{question.indent(2)}

      #{context_prompt}

      Based on this information, formulate a list of theories that might help us answer the question.

      Please respond in JSON format with the array of theories as the root element. List each theory as a single string, with no further information or structure.
    PROMPT_TEXT
  end

  def run
    result = parse_json_array(prompt(prompt_text, format: :json).full_response)
    puts "Got result: #{result.inspect}"
    result
  end
end
