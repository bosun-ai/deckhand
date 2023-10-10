class GptMigrate::MigrationAgent < ApplicationAgent
  include GptMigrate::Utils

  arguments :target_language

  attr_accessor :target_dependencies_per_file,
                :external_dependencies,
                :function_signatures,
                :globals

  def run
    @target_dependencies_per_file = Hash.new { |h, k| h[k] = [] }
    @external_dependencies = Set.new
    @function_signatures = {}

    @globals = construct_globals

    migrate(globals.entry_point)
    add_env_files()
  end

  # it recursively migrates source files, starting from the entrypoint and working its way through the
  # dependency graph. It splits dependencies based on wether they're internal or external.
  # It goes depth first on the internal dependencies, and in the base case it actually performs
  # the migration of the file, passing along the external dependencies to the migration function and
  # keeps track of the generated file for the parent file.
  def migrate(file, parent_file=nil)
    internal_dependencies, external_dependencies = get_dependencies(file)
    internal_dependencies.each do |dependency|
      migrate(dependency, file)
    end

    target_dependencies = target_dependencies_per_file[file]
    new_file_name = write_migration(file, external_dependencies, target_dependencies)
    target_deps_per_file[parent_file] << new_file_name
  end

  def write_migration(file, external_dependencies, file_dependencies)
    signatures = get_function_signatures(file_dependencies)
    
    sourcefile_content = File.read(File.join(globals.source_dir, file))

    write_migration_template = prompt_constructor(
      :hierarchy, :guidelines, :write_code, :write_migration, :singlefile,
      locals: globals.to_h.merge(
      {
        target_lang_function_signatures: convert_sigs_to_string(signatures),
        sourcefile: sourcefile,
        sourcefile_content: sourcefile_content,
        external_deps: ','.join(external_deps_list),
        target_directory_structure: build_directory_structure(globals.target_dir),
      }
    ))

    llm_write_file(write_migration_template, globals.target_dir, nil)
  end

  # Get external and internal dependencies of source file '''
  def get_dependencies(file)
    sourcefile_content = File.read(File.join(globals.source_dir, file))

    parameters = globals.to_h.merge(
      {
        source_file: file,
        source_file_content: sourcefile_content,
      }
    )
    external_deps_prompt = prompt_constructor(
      :hierarchy, :guidelines, :get_external_deps,
      locals: parameters
    )
    internal_deps_prompt = prompt_constructor(
      :hierarchy, :guidelines, :get_internal_deps,
      locals: parameters
    )

    external_dependencies_result = prompt(external_deps_prompt).full_response.strip
    
    external_deps_list = if external_dependencies_result != 'NONE'
      external_dependencies_result.split(',').map(&:strip)
    else
      []
    end

    external_deps_list.each do |dep|
      external_dependencies << dep.strip
    end

    internal_dependencies_result = prompt(internal_deps_prompt).full_response.strip
    internal_dependencies = if internal_dependencies_result != 'NONE'
      internal_dependencies_result.split(',').map(&:strip)
    else
      []
    end
    
    # Sanity checking internal dependencies to avoid infinite loops 
    if internal_dependencies.include?(file)
      puts "Warning: #{file} seems to depend on itself. Automatically removing #{file} from the list of internal dependencies."
      internal_dependencies.reject! file
    end
    
    [ internal_dependencies, external_deps_list ]
  end

  def get_function_signatures(target_files=[])
    all_sigs = []

    target_files.each do |target_file|
      if sigs = function_signatures[target_file]
        all_sigs << sigs
      else
        target_file_content = File.read(File.join(globals.target_dir, target_file))

        # function_signatures_template = prompt_constructor(HIERARCHY, GUIDELINES, GET_FUNCTION_SIGNATURES)
        prompt_template = prompt_constructor(
          :hierarchy, :guidelines, :get_function_signatures, locals: globals.to_h.merge(
          {
            targetfile_content: target_file_content,
          }
        ))

        result = prompt(prompt_template).full_response

        sigs = JSON.parse(result)
        function_signatures[target_file] = sigs
        all_sigs << sigs
      end
    end

    all_sigs
  end

  def add_env_files
    copy_files(globals.source_dir, globals.target_dir, excluded_files=EXCLUDED_FILES)

    return # not doing the docker stuff for now

    dockerfile_content = File.read(File.join(globals.target_dir, 'Dockerfile'))
    external_deps = external_dependencies.to_a.join(',')

    add_docker_requirements_prompt = prompt_constructor(
      :hierarchy, :guidelines, :write_code, :add_docker_requirements, :singlefile,
      locals: globals.to_h.merge(
      {
        target_directory_structure: build_directory_structure(globals.target_dir),
        target_lang: globals.target_lang,
        guidelines: globals.guidelines,
        dockerfile_content: dockerfile_content,
        external_deps: external_deps,
      }
    ))

    external_deps_name, _, external_deps_content = llm_write_file(add_docker_requirements_prompt, globals.target_dir, nil)

    refine_dockerfile_template = prompt_constructor(
      :hierarchy, :guidelines, :write_code, :refine_dockerfile, :singlefile,
      locals: globals.to_h.merge(
      {
        dockerfile_content: dockerfile_content,
        target_directory_structure: build_directory_structure(globals.target_dir),
        external_deps_name: external_deps_name,
        external_deps_content: external_deps_content,
        guidelines: globals.guidelines,
      }
    ))

    prompt = refine_dockerfile_template.format(
      dockerfile_content: dockerfile_content,
      target_directory_structure: build_directory_structure(globals.target_dir),
      external_deps_name: external_deps_name,
      external_deps_content: external_deps_content,
    )

    llm_write_file(prompt, globals.target_dir, "Dockerfile")
  end
end