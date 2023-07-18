module Deckhand::Tools
class ListFiles < Tool
  attr_accessor :file_path

  def self.name
    "list_files"
  end

  def self.description
    "List files in a directory"
  end

  def self.usage
    "#{name} <file_path>, for example: #{example}"
  end

  def self.example
    "#{name} ./app/models"
  end

  def self.arguments_shape
    {"file_path" => "some_path"}
  end

  def run
    self.file_path = File.join(path_prefix, arguments["file_path"] || "")

    if File.directory?(file_path)
      files = Dir.glob(@file_path + "/*").map {|f| f.delete_prefix(path_prefix + "/")}
      %Q{Files in #{@file_path}:
  #{files.join("\n").indent(2)}
  End of files
      }
    else
      if File.exist?(file_path)
        raise ToolError.new("The path `#{file_path}` is not a directory")
      else
        raise ToolError.new("The path `#{file_path}` does not exist")
      end
    end
  end
end
end