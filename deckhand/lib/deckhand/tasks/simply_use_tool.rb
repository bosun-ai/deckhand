module Deckhand::Tasks
  class SimplyUseTool < Task
    include Deckhand::Lm

    attr_accessor :tries

    def retry_history
      return "" if tries.empty?
      text = "These were your prior answers that were incorrect:\n\n"
      tries.each do |try|
        text += (
          "a. #{try[:tool_name]}\n" +
          "b. #{try[:arguments]}\n" +
          "Incorrect because: #{try[:error]}\n\n"
        ).indent(2)
      end
    end

    def tool_using_prompt
%Q{# Using functions
You are an assisstant that is helping a programmer come up with inputs to functions. The programmer is trying to answer
the following question:
  
  #{question}
  
#{context_prompt}  
  
To get the information needed to answer this question the programmer has the following fuctions at their disposal:

#{summarize_tools(tools)}

# Task

Help the programmer by answering these questions:

a. Specify the name of the tool you will use 
b. Specify the arguments you will supply to the tool

Only use 1 tool from the list of functions, give exactly the arguments as they should be supplied to the function.

#{retry_history}

# Answer

a. }
    end
  
    def run
      puts "Trying to use a tool to answer the following question: #{question}"
      @tries = []
      begin
        tool_arguments = prompt(tool_using_prompt)["message"]["content"]

        tool_name, arguments = tool_arguments.split("b. ").map(&:strip)

        puts "Trying to use tool #{tool_name} with arguments: #{arguments}"

        tool = tools.find { |t| tool_name.match?(/#{t.name}/i) }

        if tool
          puts "Using tool #{tool_name} with arguments #{arguments}"
          tool.run(arguments)
        else
          # puts "Prompt was: #{prompt_text}"
          puts "Tools were: #{tools.map(&:name).join(", ")}"
          puts "Tried to use unknown tool #{tool_name} with arguments: #{arguments}"
          raise Deckhand::Tools::ToolError.new("Must use a tool from the list of tools")
        end
      rescue Deckhand::Tools::ToolError => e
        @tries << {
          tool_name: tool_name,
          arguments: arguments,
          error: e.message
        }
        retry if tries.length < 3
        nil
      end
    end
  end
end