class GatherInformationAgent < ApplicationAgent
  arguments :question

  def prompt_text
    <<~PROMPT_TEXT
      Gathering information
      We are trying to answer the following question:

        #{question}

      #{context_prompt}

      To have a better chance of solving the question we should get answers to the following question(s):

        -
    PROMPT_TEXT
  end

  def run
    information_questions = prompt(prompt_text).full_response

    context.add_information("Tried to answer question: #{information_questions}")

    information_questions.split(' - ').map(&:strip).map do |question|
      result = run(SimplyUseToolAgent, question, context: context.dup, tools:)
      context.add_observation(result) if result
      result
    end
  end
end
