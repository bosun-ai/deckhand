class Codebase < ApplicationRecord
  after_create :create_repository

  before_validation :ensure_name_slug, unless: -> { name_slug.present? }
  validates_presence_of :name, on: :create, message: "can't be blank"
  validates_presence_of :url, on: :create, message: "can't be blank"

  CODEBASE_DIR = Rails.root.join("tmp", "code")

  def ensure_name_slug
    self.name_slug = name.parameterize if name
  end

  def path
    File.join(CODEBASE_DIR, name_slug)
  end

  def files_graph_name
    "codebase:#{id}:files"
  end

  def create_repository
    Task.run!(description: "Creating repository for #{name}", script: "git clone #{url} #{path}") do |message|
      if status = message[:status]
        update!(checked_out: status.success?)
      end
    end
  end

  # discover basic facts is going to establish a list of basic facts about the codebase
  # that we can use to make decisions about how to analyze it.
  # 
  # For example, we can use this to determine if the codebase is a Rails app, or a
  # Node app, or a Python app, etc.
  # Also what tools are used, what frameworks are used, etc.
  #
  # Specifically we need the following information:
  # - What languages and frameworks are used?
  # - For each file extension we encounter, what language is the file written in?
  # - What commands and tools can be used to execute and test the codebase?
  # - Where are entrypoints defined, where are tests defined, and where are endpoints defined?
  # - Where are dependencies defined? What external services are required?
  # - What operating system dependencies are required?
  def discover_basic_facts
    # Strategy:
    # - Recursively for each directory:
    # - Based on the files in that directory and the context of the parent directories construct a shallow context for
    #   that directory.
    # - Then for each file go through the file and establish what elements are exposed from those files.

    analyze_directory(path, root: true)
  end

  def save_directory_node(node_info, root: false)
    one_up = File.dirname(node_info[:properties][:path])

    if root
      RedisStack.graph_insert_node(files_graph_name, node_info)
    else
      target = { label: "directory", properties: { path: one_up } }
      edge = { label: "contains" }
      RedisStack.graph_attach_new(files_graph_name, target, edge, node_info)
    end
  end

  def analyze_directory(path, root: false)
    Dir.entries(path).each do |entry|
      next if entry == "." || entry == ".."

      entry_path = File.join(path, entry)
      if File.directory?(entry_path)
        analyze_directory(entry_path)
      else
        analyze_file(entry_path)
      end
    end
  end

  def analyze_file(path)

  end
end
