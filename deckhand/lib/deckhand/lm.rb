module Deckhand::Lm
  MODELS = {
    code: 'code-davinci-002',
    very_cheap: 'text-babbage-001', # $0.0005 / 1K tokens
    cheap: 'gpt-3.5-turbo', # $0.002 / 1K tokens
    instruct: 'text-davinci-003', # $0.02 / 1K tokens
    default: 'gpt-4', # $0.03 / 1K tokens
    very_large: 'gpt-4-32k' # $0.06 / 1K tokens
  }

  def embedding(text)
    response = OpenAIClient.embeddings(
      parameters: {
        model: 'text-embedding-ada-002', input: text 
      }
    )
    response["data"].first["embedding"]
  end

  def cached_embedding(text)
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

  def prompt(prompt_text, system: DEFAULT_SYSTEM, max_tokens: 2049, mode: :default)
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
    choices = response["choices"]
    if choices.count > 1
      puts "Got response with multiple choices: #{choices.inspect}"
    end
    choices.first
  end

  def all_tools
    Deckhand::Tools.constants.map { |c| Deckhand::Tools.const_get(c) }
  end

  def summarize_tools(tools)
    tools.map { |t| "* #{t.usage} # #{t.description}" }.join("\n")
  end

end