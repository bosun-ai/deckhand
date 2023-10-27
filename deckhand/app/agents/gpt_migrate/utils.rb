require 'fileutils'
require 'pathname'

module GptMigrate::Utils
  # Files that should be ignored when copying files
  EXCLUDED_FILES = [
    # Docker
    'Dockerfile',

    # Python
    'requirements.txt',
    '__pycache__/',

    # JS
    'package.json',
    'package-lock.json',
    'yarn.lock',
    'node_modules/',

    # Rust
    'Cargo.toml'

    # TODO: add more
  ]

  # Living list of file extensions that should be copied over
  INCLUDED_EXTENSIONS = [
    '.env',
    '.txt',
    '.json',
    '.csv',
    '.rdb',
    '.db'

    # TODO: add more
  ]

  INSTRUCTIONS_PREFIX = 'INSTRUCTIONS:'

  def prompt_constructor(*templates, locals: {})
    templates.map do |template|
      render template, locals:
    end.join("\n")
  end

  def files_prompt(tree, question)
    template = <<~PROMPT
      You are given the following information about the project:

      #{context.summarize_knowledge.indent(2)}

      In addition you are given the following directory structure for the project:

      #{tree.indent(2)}

      Answer the following question, give just the concise answer, not constructed as a sentence and give no explanation or reasoning:

      #{question.indent(2)}

      Answer:
    PROMPT
    prompt(template).full_response
  end

  def write_code(prompt_text)
    response = prompt(prompt_text).full_response

    if response.start_with?(INSTRUCTIONS_PREFIX)
      _, rest = response.split(INSTRUCTIONS_PREFIX, 2)
      [INSTRUCTIONS_PREFIX, '', rest.strip]
    else
      parse_code_string(response)
    end
  end

  def parse_code_string(code_string)
    sections = code_string.split('---')
    # pattern = re.compile(r'^(.+)\n```(.+?)\n(.*?)\n```', re.DOTALL)
    pattern = /^([^\n]+)\n```(.+?)\n(.*?)\n```/m
    code_triples = []
    sections.each do |section|
      match = pattern.match(section)
      if match
        filename, language, code = match.captures
        code_triples.append([section.split("\n```")[0], language.strip, code.strip])
      end
    end
    code_triples
  end

  def llm_write_file(prompt_text, target_dir, target_path)
    file_name, language, file_content = write_code(prompt_text)[0]

    return INSTRUCTIONS_PREFIX, '', file_content if file_name == INSTRUCTIONS_PREFIX

    if target_path
      File.write(File.join(target_dir, target_path), file_content)
    else
      File.write(File.join(target_dir, file_name), file_content)
    end

    [file_name, language, file_content]
  end

  def generate_directory_structure
    path = context.codebase.path
    `cd #{path} && git ls-files`
  end

  def construct_globals
    codebase = context.codebase
    source_directory_structure = generate_directory_structure
    entry_point = files_prompt(source_directory_structure, 'What file contains the entry point of this project?')
    source_language = files_prompt(source_directory_structure, 'What is the main programming language of this project?')

    GptMigrate::Globals.new(
      source_dir: context.codebase.path,
      target_dir: context.codebase.path + "_#{target_language}",
      source_lang: source_language,
      target_lang: target_language,
      entry_point:,
      source_directory_structure:,
      operating_system: 'linux',
      testfiles: [],
      source_port: nil,
      target_port: nil,
      guidelines: nil,
      ai: nil
    )
  end

  def list_all_files(path)
    `cd #{path} && git ls-files`.lines.map(&:strip).map { |p| Pathname(p) }
  end

  def copy_files(source_dir, target_dir, excluded_files = [])
    entries = list_all_files(source_dir)

    entries.each do |item|
      item_s = item.to_s

      # TODO: more complete logic
      next if excluded_files.any? { |excluded_file| item_s.include?(excluded_file) }
      next unless INCLUDED_EXTENSIONS.any? { |extension| item_s.end_with?(extension) }

      source_file = File.expand_path(item, source_dir)
      target_file = File.expand_path(item, target_dir)

      target_file.parent.mkpath
      FileUtils.cp(source_file, target_file)
    end
  end
end
