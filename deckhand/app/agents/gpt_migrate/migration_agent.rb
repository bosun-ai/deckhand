class GptMigrate::MigrationAgent < ApplicationAgent
  include GptMigrate::Utils

  arguments :target_language

  attr_accessor :target_dependencies_per_file

  def run
    @target_dependencies_per_file = Hash.new { |h, k| h[k] = [] }
    # it recursively migrates source files, starting from the entrypoint and working its way through the
    # dependency graph. It splits dependencies based on wether they're internal or external.
    # It goes depth first on the internal dependencies, and in the base case it actually performs
    # the migration of the file, passing along the external dependencies to the migration function and
    # keeps track of the generated file for the parent file.
    globals = construct_globals

    migrate(globals.entry_point, globals)
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

  def write_migration(file, external_dependencies, file_dependencies, globals)
    signatures = get_function_signatures(file_dependencies, globals)
    
    # write_migration_template = prompt_constructor(HIERARCHY, GUIDELINES, WRITE_CODE, WRITE_MIGRATION, SINGLEFILE)
    write_migration_template = prompt_constructor(:hierarchy, :guidelines, :write_code, :write_migration, :singlefile)

    sourcefile_content = File.read(File.join(globals.source_dir, file))
    
    migration_prompt = render('write_migration_template', locals: globals.to_h.merge(
      {
        targetlang_function_signatures: convert_sigs_to_string(sigs),
        sourcefile: sourcefile,
        sourcefile_content: sourcefile_content,
        external_deps: ','.join(external_deps_list),
        target_directory_structure: build_directory_structure(globals.targetdir),
      }
    ))
  end

  def get_function_signatures(target_files=[], globals)
    all_sigs = []
    target_files.each do |target_file|
      sigs_file_name = target_file + "_sigs.json"
      if file_exists_in_memory(sigs_file_name)
        sigs = read_json_from_memory(sigs_file_name)
        all_sigs.extend(sigs)
      else
        target_file_content = File.read(File.join(globals.target_dir, target_file))
        prompt = render 'function_signatures_template', locals: globals.to_h.merge(
          {
            targetfile_content: target_file_content,
          }
        )
        sigs = JSON.parse(llm_run(prompt,
                                  waiting_message: "Parsing function signatures for {target_file}...",
                                  success_message: None,
                                  globals: globals))
        all_sigs.extend(sigs)
        write_json_to_memory(sigs_file_name, sigs)
      end
    end
    return all_sigs
  end
end