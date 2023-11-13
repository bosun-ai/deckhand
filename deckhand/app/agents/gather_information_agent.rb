class GatherInformationAgent < ApplicationAgent 
  arguments :question

  def prompt_text
    <<~PROMPT_TEXT
      Gathering information
      We are trying to answer the following question:

        #{question}

      #{context_prompt}

      Give a list of the questions we should get answers to so that we have a good chance of answering the question.

      #{return_json_array('questions')}
    PROMPT_TEXT
  end

  def run
    information_questions = parse_json_array(prompt(prompt_text).full_response)

    # context.add_information("Tried to answer question: #{information_questions}")

    information_questions.map do |question|
      result = run(SimplyUseToolAgent, question, context: context.dup, tools: tools).output
      # context.add_observation(result) if result
      result
    end.compact
  end
end
