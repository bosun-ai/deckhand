class SimplyUseToolAgent < ApplicationAgent
  arguments :question

  attr_accessor :tries

  def retry_history
    return "" if tries.empty?
    text = "These were your prior answers that were incorrect:\n\n"
    tries.each do |try|
      text += ("a. #{try[:tool_name]}\n" +
                "b. #{try[:arguments]}\n" +
                "Incorrect because: #{try[:error]}\n\n").indent(2)
    end
  end

  def non_function_prompt_text
    <<~PROMPT_TEXT
      # Using functions
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

      a. 
    PROMPT_TEXT
  end

  def prompt_text
    <<~PROMPT_TEXT
      # Using functions

      #{question}

      #{context_prompt}  

      ## Task
      Use a function to get more information to answer the question.

      You have access to the full filesystem and any devices exposed through the functions.

      Make sure you give the functions exact parameters, not examples.
    PROMPT_TEXT
  end

  def run
    result = prompt(prompt_text, functions: tools.map(&:openai_signature))
    if result.is_a? Deckhand::Lm::PromptResponse
      result.full_response
    else
      result
    end
  end

  def non_function_run
    puts "Trying to use a tool to answer the following question: #{question}"
    @tries = []
    begin
      tool_arguments = prompt(prompt_text).full_response

      tool_name, arguments = tool_arguments.split("b. ").map(&:strip)

      puts "Trying to use tool #{tool_name} with arguments: #{arguments}"

      tool = tools.find { |t| tool_name.match?(/#{t.name}/i) }

      if tool
        puts "Using tool #{tool_name} with arguments #{arguments}"
        tool.run(arguments, context: context)
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
        error: e.message,
      }
      retry if tries.length < 3
      nil
    end
  end
end
