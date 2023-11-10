module ApplicationAgent::Helpers
  def self.included(base)
    base.extend ClassMethods
  end
    
  module ClassMethods
  end

  def context_prompt
    return '' if context.blank?

    <<~CONTEXT_PROMPT
      You are given the following context to the question:
      #{'  '}
      #{context.summarize_knowledge.indent(2)}
    CONTEXT_PROMPT
  end

  def summarize_tools(tools)
    tools.map { |t| "  * #{t.name}: #{t.description}\n#{t.usage.indent(2)}" }.join("\n")
  end

  def render(template_name, locals: {})
    template = read_template_file(template_name.to_s)
    template.render!(locals.with_indifferent_access, { strict_variables: true, strict_filters: true })
  end

  def logger
    Rails.logger
  end

  def parse_json(json)
    # sometimes it is surrounded with markdown codeblock quotes and the json prefix, so try to remove that:
    JSON.parse(json.gsub(/^\s*```(json)?/, "").gsub(/```\s*$/, ""))
  end

  def parse_json_array(json)
    result = parse_json(json)
    if result.is_a? Array
      result
    elsif result.is_a? Hash
      result.values.flatten
    else
      [result]
    end
  end

  private

  def read_template_file(template_name)
    template = Liquid::Template.new

    dir_name = self.class.name.underscore.chomp('_agent')
    dir = Rails.root / 'app' / 'agents' / 'templates' / dir_name
    file_system = Liquid::LocalFileSystem.new(dir)
    template.registers[:file_system] = file_system

    file_path = dir / (template_name.to_s + '.liquid')
    raise "Could not find agent template file: #{file_path}" unless file_path.exist?

    template.parse(file_path.read, error_mode: :strict)
  end
end