module Deckhand::Tasks
class GatherInformation
  include Deckhand::Lm

  attr_accessor :context, :tools, :question

  def initialize(question, context: [], tools: all_tools)
    @question = question
    @tools = tools
    @context = context
  end

  def context_prompt
    if context.blank?
      ""
    else
      %Q{We have the following information about the context of the question:
        
#{context.join("\n\n").indent(2)}

}
    end
  end

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