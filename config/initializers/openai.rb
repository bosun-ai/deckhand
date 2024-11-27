OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_ACCESS_TOKEN', 'your-openai-access-token')

  if (azure_endpoint = ENV.fetch('OPENAI_AZURE_ENDPOINT', nil))
    config.uri_base = azure_endpoint
    config.api_type = :azure
    config.api_version = '2023-05-15'
  end

  # config.organization_id = ENV.fetch('OPENAI_ORGANIZATION_ID') # Optional.
end

OpenAIClient = OpenAI::Client.new
