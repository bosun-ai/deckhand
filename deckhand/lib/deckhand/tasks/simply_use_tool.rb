module Deckhand::Tasks
  class SimplyUseTool
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
        %Q{You are given the following context to the question:
          
  #{context.join("\n\n").indent(2)}
  
  }
      end
    end
  
    def run
      prompt_text = %Q{# Using a tool 
You are trying to answer the following question:
  
  #{question}
  
#{context_prompt}  
  
To get the information needed to answer this question you have the following tools at your disposal:

#{summarize_tools(tools)}

# Task

Complete the following tasks:

a. Name the tool you will use to answer the question.
b. Describe what arguments you will give to the tool.

Be concise.

# Solution

a. }
      tool_arguments = prompt(prompt_text)["message"]["content"]

      tool_name, arguments = tool_arguments.split("b. ").map(&:strip)

      puts "Trying to use tool #{tool_name} with arguments: #{arguments}"

      tool = tools.find { |t| t.name.match?(tool_name) }

      if tool
        puts "Using tool #{tool_name} with arguments #{arguments}"
        tool_response = tool.run(arguments)
        return tool_response
      else
        puts "Prompt was: #{prompt_text}"
        puts "Tried to use unknown tool #{tool_name} with arguments: #{arguments}"
      end
    end
  end
end