class SimplyUseToolAgent < ApplicationAgent
  arguments :question

  attr_accessor :tries

  def retry_history
    return '' if tries.empty?

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
      #{'  '}
      #{question}
      #{'  '}
      #{context_prompt}#{'  '}

      To get the information needed to answer this question the programmer has the following fuctions at their disposal:

      #{summarize_tools(tools)}

      # Task

      Help the programmer by answering these questions:

      a. Specify the name of the tool you will use#{' '}
      b. Specify the arguments you will supply to the tool

      Only use 1 tool from the list of functions, give exactly the arguments as they should be supplied to the function.

      #{retry_history}

      # Answer

      a.#{' '}
    PROMPT_TEXT
  end

  def prompt_text
    text = <<~PROMPT_TEXT
      # Using functions

      #{question}

      #{context_prompt}#{'  '}

      ## Task
      Use a function to get more information to answer the question.

      You have access to the full filesystem and any devices exposed through the functions.

      Make sure you give the functions exact parameters, not examples.
    PROMPT_TEXT

    if @tries.any?
      text += "\n\nYou have tried before but failed with the following messages:\n\n#{@tries.join("\n").indent(2)}\n"
    end

    text
  end

  def run
    tools = tool_classes
    @tries = []
    begin
      result = prompt(prompt_text, functions: tools.map(&:openai_signature))
      result.full_response
    rescue => e
      # TODO make this catch only the specific errors, so it doesn't mess up the regular run error flow
      raise e if e.is_a?(RunAgainLater) || e.is_a?(RunDeferred)
      Rails.logger.error("SimplyUseToolAgent##{agent_run.id} rescued error: #{e.inspect}:\n#{e.backtrace.join("\n")}")
      @tries << e.message
      retry if @tries.length < 4
      logger.error "Tried 4 times but could not recover from tool use error in SimplyUseToolAgent: #{e.message}. #{@tries.inspect}"
      nil
    end
  end

  def non_function_run
    puts "Trying to use a tool to answer the following question: #{question}"
    @tries = []
    begin
      tool_arguments = prompt(prompt_text).full_response

      tool_name, arguments = tool_arguments.split('b. ').map(&:strip)

      puts "Trying to use tool #{tool_name} with arguments: #{arguments}"

      tool = tools.find { |t| tool_name.match?(/#{t.name}/i) }

      if tool
        logger.info "Using tool #{tool_name} with arguments #{arguments}"
        tool.run(arguments, context:)
      else
        # puts "Prompt was: #{prompt_text}"
        logger.error "Tools were: #{tools.map(&:name).join(', ')}"
        logger.error "Tried to use unknown tool #{tool_name} with arguments: #{arguments}"
        raise ApplicationTool::Error, 'Must use a tool from the list of tools'
      end
    rescue ApplicationTool::Error => e
      @tries << {
        tool_name:,
        arguments:,
        error: e.message
      }
      retry if tries.length < 3
      logger.error "Tried 3 times but could not recover from tool use error in SimplyUseToolAgent: #{e.message}. #{@tries.inspect}"
      nil
    rescue StandardError => e
      logger.error "Unchecked tool eeror: #{e.class}: #{e.message} in SimplyUseToolAgent."
      nil
    end
  end
end
