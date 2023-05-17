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

  DEFAULT_SYSTEM = "You are a helpful assistant that provides information without formalities."

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

    response = OpenAIClient.chat(parameters: parameters)
    # Rails.logger.info "Prompted #{parameters.inspect} and got: #{response.inspect}"
    puts response["choices"].inspect
    response["choices"].first
  end

  def self.tool_using_and_chaining_prompt(tools)
    %Q{
To make sure the final answer is correct start out by listing observations based on the information you have about
the problem so far. Start each observation with the string "O: ". Start your final answer with the string "A: ". If
you don't have enough information to answer the question you can instead request information from a tool.

The following tools are available:

#{tools.map { |t| "* #{t.name}: #{t.description}" }.join("\n")}

You can use these tools by prefixing your answer with a question mark (?) and then the name of the tool and then your question. For example:

?#{tools.first.name} #{tools.first.example}

The result of the of the tool will be appended to your answer prefixed with a greater than sign (>).      

A full example of an interaction could be:

```
Question:
Given a codebase with the following files in the root directory:

- Gemfile
- README.md
- app.rb
- test.rb

What command should I run to run the tests?

Answer:
O: The codebase has a Gemfile
?analyze_file Gemfile What test framework is referenced in this file?
> RSpec
O: The codebase uses RSpec
A: bundle exec rspec
```

This concludes the instructions. Now answer the following question:

#{question}
}

  end
end