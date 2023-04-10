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

  def self.prompt(prompt_text, max_tokens: 2049, mode: :default)
    model = MODELS[mode]
    parameters = {
      model: model,
      messages: [
        { role: 'system', 'content': 'You are a helpful assistant that provides information without formalities.'},
        { role: 'user', 'content': prompt_text }
      ],
      max_tokens: max_tokens
    }

    response = OpenAIClient.chat(parameters: parameters)
    # Rails.logger.info "Prompted #{parameters.inspect} and got: #{response.inspect}"
    puts response["choices"].inspect
    response["choices"].first
  end
end