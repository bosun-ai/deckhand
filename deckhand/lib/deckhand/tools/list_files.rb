module Deckhand::Tools
class ListFiles < Tool
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

  def self.arguments_shape
    {"file_path" => "some_path"}
  end

  def run
    self.file_path = arguments["file_path"]
  
    files = Dir.glob(@file_path + "/*")
    %Q{Files in #{@file_path}:
#{files.join("\n").indent(2)}
End of files
    }
  end
end
end