namespace :redis do
  desc "Flush database"
  task "flushdb" => :environment do
    puts "Flushing redis db.."
    RClient.flushdb
    puts "Done flushing redis db"
  end

  desc "Create indexes"
  task "create_indexes" => :environment do
    [
      Fact,
    ].each do |model|
      puts "Creating index for #{model}.."
      model.create_index
      puts "Done creating index for #{model}"
    end
  end

  desc "Recreate database"
  task "recreate" => :environment do
    Rake::Task["redis:flushdb"].invoke
    Rake::Task["redis:create_indexes"].invoke
  end
end
