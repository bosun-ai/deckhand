module Deckhand::Tasks
class GatherInformation
  attr_accessor :history, :tools, :question

  def initialize(question, history: [], tools: all_tools)
    @question = question
    @tools = tools
    @history = history
  end

  def history_prompt
    if history.blank?
      ""
    else
      %Q{We have the following information about the context of the question:
        
#{history.join("\n\n").indent(2)}

}
    end
  end

  def run
    prompt_text = %Q{# Gathering information
We are trying to answer the following question:

  #{question}

#{history_prompt}  

To have a better chance of solving the question we should get answers to the following question(s):

  - }
    information_questions = prompt(prompt_text)["message"]["content"]

    information_questions.split(" - ").map(&:strip).each do |question|
      result = SimplyUseTool.new(question, tools: tools).run
      history.push result if result
    end
  end
end