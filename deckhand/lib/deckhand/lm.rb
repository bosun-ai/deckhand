class Deckhand::Lm
  MODELS = {
    code: 'code-davinci-002',
    very_cheap: 'text-babbage-001', # $0.0005 / 1K tokens
    cheap: 'gpt-3.5-turbo', # $0.002 / 1K tokens
    instruct: 'text-davinci-003', # $0.02 / 1K tokens
    default: 'gpt-4', # $0.03 / 1K tokens
    very_large: 'gpt-4-32k' # $0.06 / 1K tokens
  }

  def self.embedding(text)
    response = OpenAIClient.embeddings(
      parameters: {
        model: 'text-embedding-ada-002', input: text 
      }
    )
    response["data"].first["embedding"]
  end

  def self.cached_embedding(text)
    text_hash = Digest::SHA256.hexdigest(text)
    if embedding = RClient.json_get("embeddings_cache:#{text_hash}", "$.v")
      embedding.first
    else
      embedding = self.embedding(text)
      RClient.json_set("embeddings_cache:#{text_hash}", "$", { v: embedding })
      embedding
    end
  end

  DEFAULT_SYSTEM = "You are a helpful assistant that provides information without formalities"

  def self.formatted_prompt_system(format, example: nil)
    DEFAULT_SYSTEM.gsub(".", ", formatting your answers as #{format} documents. For example an answer could be:\n#{example}\n")
  end

  def self.prompt(prompt_text, system: DEFAULT_SYSTEM, max_tokens: 2049, mode: :default)
    model = MODELS[mode]
    parameters = {
      model: model,
      messages: [
        { role: 'system', 'content': system},
        { role: 'user', 'content': prompt_text }
      ],
      max_tokens: max_tokens
    }

    puts "Prompting.."
    # puts "\n----\n#{prompt_text}\n----\n"
    response = OpenAIClient.chat(parameters: parameters)
    # Rails.logger.info "Prompted #{parameters.inspect} and got: #{response.inspect}"
    # puts response["choices"].inspect
    response["choices"].first
  end

  def self.all_tools
    Deckhand::Tools.constants.map { |c| Deckhand::Tools.const_get(c) }
  end

  def self.tool_using_and_chaining_prompt(question, tools: all_tools)
    history = []
    # TODO maybe also postulate theories before running tools?

    loop do
      prompt_text = %Q{
# Solving a problem with tools

To make sure the final answer is correct work it out step by step by formulating thoughts and observations based on the information you have about
the problem. Start each observation with the string "O: ". Start each thought with the string "T: ". Start your final answer with the string "A: ". When
you need more information to answer the question definitively request information from a tool.

The following tools are available:

#{tools.map { |t| "* #{t.usage} # #{t.description}" }.join("\n")}

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

## Interaction history

These are the steps already taken to answer the question:

#{history.join("\n")}

## Next step or answer

This is the next step you should take or the final answer:
}
      responses = prompt(prompt_text)["message"]["content"].lines.reject(&:blank?).map(&:strip)
      responses.each do |response|
        # puts "Response from LLM:\n----\n#{response}\n----\n"
        history << response
        if response =~ /O:/
          history << response
          puts "Made observation: #{history.last}"
        elsif response =~ /T:/
          history << response
          puts "Formulated theory: #{history.last}"
        elsif response =~ /A:/
          puts "Gave answer: #{response}"
          return response
        elsif response =~ /\?(.*)/
          tool_name, arguments = $1.split(" ", 2)

          tool = tools.find { |t| t.name == tool_name }

          if tool
            puts "Using tool #{tool_name} with arguments #{arguments}"
            tool_response = tool.run(*arguments)
            history << "> #{tool_response}"
            # puts "Got response from tool: #{tool_response}"
          else
            puts "Unknown tool: #{tool_name}"
            return response
          end
        else
          puts "Unknown response: #{response}"
          history << "E: You said: #{response}, but did not give a prefix to indicate if this was a thought, observation, tool request or answer. Please try again."
        end
      end
    end
  end
end