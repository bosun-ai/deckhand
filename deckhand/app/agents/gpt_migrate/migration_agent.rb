class GptMigrate::MigrationAgent < ApplicationAgent
  arguments :target_language

  attr_accessor :target_dependencies_per_file

  def codebase_prompt(question)
  end

  def generate_directory_structure
    path = context.codebase.path
  end

  def run
    @target_dependencies_per_file = Hash.new { |h, k| h[k] = [] }
    # it recursively migrates source files, starting from the entrypoint and working its way through the
    # dependency graph. It splits dependencies based on wether they're internal or external.
    # It goes depth first on the internal dependencies, and in the base case it actually performs
    # the migration of the file, passing along the external dependencies to the migration function and
    # keeps track of the generated file for the parent file.

    entry_point = codebase_prompt("What is the entry point of this project")
    source_directory_structure = generate_directory_structure

    globals = GptMigrate::Globals.new(
      source_dir: context.codebase.path,
      target_dir: context.codebase.path + "_#{target_language}",
      source_lang: codebase_prompt("What is the source language of this project"),
      target_lang: target_language,
      source_entry: entry_point,
      source_directory_structure: source_directory_structure,
      operating_system: "linux",
      testfiles: codebase_prompt("What files should be tested?"),
      sourceport: nil,
      targetport: nil,
    )

    migrate(entry_point, globals)
    add_env_files(globals)
  end

  def migrate(file, globals, parent_file=nil)
    internal_dependencies, external_dependencies = get_dependencies(file, globals)
    internal_dependencies.each do |dependency|
      migrate(dependency, globals, file)
    end

    target_dependencies = target_dependencies_per_file[file]
    new_file_name = write_migration(file, external_dependencies, target_dependencies, globals)
    target_deps_per_file[parent_file] << new_file_name
  end

  def write_migration(file, external_dependencies, target_dependencies, globals)
    
  end

end