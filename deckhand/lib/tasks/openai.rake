namespace :openai do
  desc "Lists all info about the OpenAI models"
  task "info", [:model] => :environment do |_, args|
    if args[:model]
      model = OpenAIClient.models.retrieve(id: args[:model])
      puts "Model:\n #{model.to_s}"
    else
      models = OpenAIClient.models.list["data"]
      puts "Models:\n#{models.map { |m| m["id"] }.inspect}"
    end
  end
end
