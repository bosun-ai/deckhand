class Deckhand::Tools::ListFiles
  def self.name
    "list_files"
  end

  def self.description
    "List files in a directory"
  end

  def self.usage
    "#{name} <file_path>"
  end

  def self.example
    "#{name} app/models"
  end

  def self.run(args)
    file_path = args
    new(file_path).run()
  end

  def initialize(file_path)
    @file_path = file_path
  end

  def run
    files = Dir.glob(@file_path + "/*")
    %Q{Files in #{@file_path}:
#{files.join("\n")}
    }
  end
end