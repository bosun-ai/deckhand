class InvestigateWithToolsAgent < ApplicationAgent
  arguments :question

  def prompt_text
    render prompt: {
      tools_summary: 'No tools available',
      tools: [{ name: 'a_tool', usage: 'with_usage'}],
      question: question,
      context: context.summarize_knowledge
    }
  end

  def run
    # TODO: it hallucinates sequences sometimes. To fix this I think we have to split up the prompts into generating
    # theories and observations, and then asking if based on the information it can make a conclusive answer or if it
    # needs more information. This can be combined with the fancy step of solving each theory as a separate problem
    # seperately and then combining the results.

    context = []

    loop do
      responses = prompt(prompt_text)["message"]["content"].lines.reject(&:blank?).map(&:strip)
      responses.each do |response|
        # puts "Response from LLM:\n----\n#{response}\n----\n"
        if response =~ /O:/
          context << response
          puts "Made observation: #{context.last}"
        elsif response =~ /T:/
          context << response
          puts "Formulated theory: #{context.last}"
        elsif response =~ /A:/
          puts "Gave answer: #{response}"
          return response
        elsif response =~ /\?(.*)/
          tool_name, arguments = $1.split(" ", 2)

          tool = tools.find { |t| t.name == tool_name }

          if tool
            puts "Using tool #{tool_name} with arguments #{arguments}"
            tool_response = tool.run(*arguments, context: context)
            context << "> #{tool_response}"
            # puts "Got response from tool: #{tool_response}"
          else
            puts "Unknown tool: #{tool_name}"
            return response
          end
        else
          puts "Unknown response: #{response}"

          puts "\n\ncontext: #{context.inspect}\n\n"
          puts "\n\nPrompt: #{prompt_text}\n\n"
          puts "\n\nResponses: #{responses.inspect}\n\n"

          raise "Unknown response: #{response}"

          context << "E: You said: #{response}, but did not give a prefix to indicate if this was a thought, observation, tool request or answer. Please try again."
        end
      end
    end
  end
end
