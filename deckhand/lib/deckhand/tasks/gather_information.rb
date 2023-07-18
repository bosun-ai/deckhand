module Deckhand::Tasks
  class GatherInformation < Task
    def run
      prompt_text = %Q{# Gathering information
We are trying to answer the following question:

  #{question}

#{context_prompt}

To have a better chance of solving the question we should get answers to the following question(s):

  - }
      information_questions = prompt(prompt_text)["message"]["content"]

      puts "Trying to answer the following question(s): #{information_questions}"

      context.add_information("Tried to answer question: #{information_questions}")

      information_questions.split(" - ").map(&:strip).each do |question|
        result = SimplyUseTool.run(question, context: context, tools: tools)
        if result
          context.add_observation(result)
        end
      end
    end
  end
end
