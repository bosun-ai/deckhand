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

    information_questions.split(" - ").map(&:strip).each do |question|
      result = SimplyUseTool.new(question, context: context, tools: tools).run
      if result
        context.push "O: #{result}"
      else
        context.push "Q: #{question}"
      end
    end
  end
end
end