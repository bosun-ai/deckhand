module Deckhand::Tasks
  class InvestigateWithTools < Task
    include Deckhand::Lm

    def prompt_text
      %Q{# Solving a problem with tools

To make sure the final answer is correct work it out step by step by formulating thoughts and observations based on the information you have about
the problem. Start each observation with the string "O: ". Start each thought with the string "T: ". Start your final answer with the string "A: ". When
you need more information to answer the question definitively request information from a tool.

The following tools are available:

#{summarize_tools(tools)}

You can use these tools by prefixing your answer with a question mark (?) and then the name of the tool and then your question. For example:

?#{tools.first.name} #{tools.first.example}

The result of the of the tool will be appended to your answer prefixed with a greater than sign (>).      

## Example

A full example of an interaction could be:

```
Question:

What command should I run to run the tests?

Answer:
T: To know what command to run to run the tests I need to know what test framework is used
?list_files .
> Files in .:
./Gemfile
./README.md
./app.rb
./spec
T: If a codebase has a Gemfile it might contain a reference to a test framework
T: If a codebase has a spec directory it might use RSpec
?analyze_file Gemfile what test frameworks are required by the Gemfile?
> RSpec
T: If a codebase has a Gemfile it uses bundler to run commands
A: bundle exec rspec
```

This concludes the instructions.

## Assignment

This is the question you are trying to answer:

```
#{question}
```

## Interaction context

These are the steps already taken to answer the question:

#{context.join("\n")}

## Next step or answer

This is the next step you should take or the final answer:
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
end
