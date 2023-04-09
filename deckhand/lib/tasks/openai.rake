namespace :openai do
  desc "Lists all info about the OpenAI models"
  task "info" => :environment do
    models = OpenAIClient.models.list
    puts "Models:\n#{models.to_s}"
  end
end
