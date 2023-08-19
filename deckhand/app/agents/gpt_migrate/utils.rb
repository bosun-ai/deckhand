module GptMigrate::Utils
  def prompt_constructor(templates)
    templates.map do |template|
      render template, locals: globals.to_h
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

  def generate_directory_structure
    path = context.codebase.path
    `cd #{path} && git ls-files`
  end

  def construct_globals
    codebase = context.codebase
    source_directory_structure = generate_directory_structure
    entry_point = files_prompt(source_directory_structure, "What file contains the entry point of this project?")
    source_language = files_prompt(source_directory_structure, "What is the main programming language of this project?")

    GptMigrate::Globals.new(
      source_dir: context.codebase.path,
      target_dir: context.codebase.path + "_#{target_language}",
      source_lang: source_language,
      target_lang: target_language,
      entry_point: entry_point,
      source_directory_structure: source_directory_structure,
      operating_system: "linux",
      testfiles: [],
      source_port: nil,
      target_port: nil,
      guidelines: nil,
      ai: nil
    )
  end
end