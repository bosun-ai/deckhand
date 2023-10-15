class Codebase::FileAnalysis::FilesystemFacts < T::Struct
  prop :codebase, Codebase
  prop :root_path, String

  # Strategy:
  # - Recursively for each directory:
  # - Based on the files in that directory and the context of the parent directories construct a shallow context for
  #   that directory.
  def self.run(codebase)
    new(codebase: codebase, root_path: codebase.path)
      .analyze_directory(codebase.path, root: true)
  end

  def save_file_entry_node(node_info, root: false)
    one_up = File.dirname(node_info[:properties][:path])

    if root
      RedisStack.graph_insert_node(codebase.files_graph_name, node_info)
    else
      target = { label: "directory", properties: { path: one_up } }
      edge = { label: "contains" }
      RedisStack.graph_attach_new(codebase.files_graph_name, target, edge, node_info)
    end
  end

  def analyze_directory(path, root: false)
    base_name = File.basename(path)
    relative_path = path.gsub(root_path + "/", "")
    node = {
      labels: ["directory"],
      properties: {
        path: relative_path,
        name: base_name,
      },
    }

    # TODO we should be prompting the LLM to determine if we should recurse into this directory
    if base_name == ".git"
      node[:properties][:git_dir] = true
      return node
    end
    if base_name == "node_modules"
      node[:properties][:node_modules] = true
      return node
    end

    ignored = `cd #{root_path}; git check-ignore #{relative_path}`
    if ignored.present?
      node[:properties][:git_ignored] = true
      return node
    end

    save_file_entry_node(node, root: root)

    child_properties = {}
    Dir.entries(path).each do |entry|
      next if entry == "." || entry == ".."

      entry_path = File.join(path, entry)
      child_properties[entry] = if File.directory?(entry_path)
          analyze_directory(entry_path)
        else
          analyze_file(entry_path)
        end
    end

    # we count the file extensions of the files that we just analyzed
    extensions = child_properties.values.reduce({}) do |acc, child|
      if child[:labels].include?("file")
        ext = child[:properties][:ext]
        acc[ext] ||= 0
        acc[ext] += 1
      elsif child[:labels].include?("directory")
        next acc unless child[:properties][:file_extensions]
        child[:properties][:file_extensions].each do |ext, count|
          acc[ext] ||= 0
          acc[ext] += count
        end
      end
      acc
    end

    node[:properties][:file_extensions] = extensions

    node
  end

  def analyze_file(path)
    base_name = File.basename(path)
    relative_path = path.gsub(root_path + "/", "")
    node = {
      labels: ["file"],
      properties: {
        path: relative_path,
        name: base_name,
        ext: File.extname(path),
      },
    }

    save_file_entry_node(node)

    node
  end
end
