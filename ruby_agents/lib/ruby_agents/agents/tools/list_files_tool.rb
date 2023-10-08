class ListFilesTool < ApplicationTool
  arguments :file_path

  def self.name
    "list_files"
  end

  def self.description
    "List entries in a directory on the filesystem"
  end

  def self.usage
    "#{name} <file_path>, for example: #{example}"
  end

  def self.example
    "#{name} ./app/models"
  end

  def self.arguments_shape
    { "file_path" => "some_path" }
  end

  def self.parameters
    {
      type: :object,
      properties: {
        file_path: {
          type: :string,
          description: "The path of which to list the entries",
        },
      },
      required: ["file_path"],
    }
  end

  def run
    relative_path = file_path || "."
    self.file_path = File.join(path_prefix, relative_path)

    if File.directory?(file_path)
      directories, files = Dir.glob(File.join(@file_path, "*"))
        .map { |f| "- #{Pathname.new(f).relative_path_from(path_prefix)}}" }
        .sort
        .partition { |f| File.directory?(File.join(path_prefix, f)) }
      <<~FILES
        Files in #{relative_path}:
          #{files.join("\n").indent(2)}

        Directories in #{relative_path}:
          #{directories.join("\n").indent(2)}
      FILES
    else
      if File.exist?(file_path)
        raise ToolError.new("The path `#{relative_path}` is not a directory")
      else
        raise ToolError.new("The path `#{relative_path}` does not exist")
      end
    end
  end
end
