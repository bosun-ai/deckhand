OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_ACCESS_TOKEN', 'your-openai-access-token')
  # config.organization_id = ENV.fetch('OPENAI_ORGANIZATION_ID') # Optional.
end

OpenAIClient = OpenAI::Client.new