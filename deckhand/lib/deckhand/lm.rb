module Deckhand::Lm
  MODELS = {
    code: 'code-davinci-002',
    very_cheap: 'text-babbage-001', # $0.0005 / 1K tokens
    cheap: 'gpt-3.5-turbo-1106', # $0.002 / 1K tokens
    instruct: 'text-davinci-003', # $0.02 / 1K tokens
    default: 'gpt-4-1106-preview', # $0.03 / 1K tokens
    very_large: 'gpt-4-1106-preview' #
  }

  def self.embedding(text)
    response = OpenAIClient.embeddings(
      parameters: {
        model: 'text-embedding-ada-002', input: text
      }
    )
    response['data'].first['embedding']
  end

  def self.cached_embedding(text)
    text_hash = Digest::SHA256.hexdigest(text)
    if embedding = RClient.json_get("embeddings_cache:#{text_hash}", '$.v')
      embedding.first
    else
      embedding = self.embedding(text)
      RClient.json_set("embeddings_cache:#{text_hash}", '$', { v: embedding })
      embedding
    end
  end

  DEFAULT_SYSTEM = 'You are a helpful assistant that provides information without formalities.'

  def self.prompt(prompt_text, functions: nil, system: DEFAULT_SYSTEM, max_tokens: 4096, mode: :default, format: nil, **other_options)
    DeckhandTracer.in_span('PROMPT') do
      current_span = OpenTelemetry::Trace.current_span
      current_span.add_event('prompt',
                             attributes: { prompt: prompt_text, system:, max_tokens:, mode: mode.to_s }.stringify_keys)

      model = MODELS[mode]
      parameters = {
        model:,
        messages: [
          { role: 'system', 'content': system },
          { role: 'user', 'content': prompt_text }
        ],
        max_tokens:
      }

      if format == :json
        parameters[:response_format] = { 'type': 'json_object' }
      end

      parameters[:functions] = functions if functions.present?

      parameters.merge!(other_options)

      tries = 0
      response = nil
      begin
        response = OpenAIClient.chat(parameters:)
        choices = response['choices']
        if choices.nil?
          raise "Invalid OpenAI response: #{response.inspect}"
        elsif choices.count > 1
          raise "Got response with multiple choices: #{choices.inspect}"
        end
      rescue StandardError => e
        tries += 1
        raise e unless tries < 3

        puts 'Retrying...'
        sleep 5
        retry
      end
      current_span.add_event('prompt_response',
                             attributes: { response: response.dig('choices', 0, 'message').to_s }.stringify_keys)
      # Rails.logger.info "Prompted #{parameters.inspect} and got: #{response.inspect}"
      PromptResponse.new(response, prompt: prompt_text, options: parameters)
    end
  end

  class PromptResponse
    attr_accessor :raw_response, :prompt, :options

    def initialize(response, prompt: nil, options: nil)
      @raw_response = response
      @prompt = prompt
      @options = options
    end

    def self.from_json(response)
      response = response.with_indifferent_access
      new(response[:response], prompt: response[:prompt], options: response[:options])
    end

    def as_json(*_args)
      {
        prompt:,
        options:,
        response: raw_response
      }
    end

    def to_json(*args)
      as_json.to_json(*args)
    end

    def full_response
      if is_function_call?
        "function_call #{function_call_name} #{function_call_args.inspect}"
      else
        message['content']
      end
    end

    def message
      raw_response.dig('choices', 0, 'message')
    end

    def is_function_call?
      message && message['role'] == 'assistant' && message['function_call']
    end

    def function_call_name
      return nil unless is_function_call?

      function_name = message.dig('function_call', 'name')
    end

    def function_call_args
      return nil unless is_function_call?

      JSON.parse(
        message.dig('function_call', 'arguments'),
        { symbolize_names: true }
      )
    end
  end

  def prompt(prompt_text, system: DEFAULT_SYSTEM, max_tokens: 2049, mode: :default)
    Deckhand::Lm.prompt(prompt_text, system:, max_tokens:, mode:)
  end

  def self.all_tools
    # HACK: next line is needed to load all tools in development mode
    Deckhand::Tools.constants.map { |c| Deckhand::Tools.const_get(c) }
    Deckhand::Tools::Tool.descendants
  end

  def summarize_tools(tools)
    tools.map { |t| "  * #{t.name}: #{t.description}\n#{t.usage.indent(2)}" }.join("\n")
  end
end
