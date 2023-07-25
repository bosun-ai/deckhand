class GatherInformationActor < ApplicationActor 
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

    information_questions.split(" - ").map(&:strip).each do |question|
      result = run(SimplyUseToolActor, question, context: context.dup, tools: tools)
      if result
        context.add_observation(result)
      end
    end
  end
end
