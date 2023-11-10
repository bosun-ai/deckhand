module ApplicationAgent::Helpers
  def self.included(base)
    base.extend ClassMethods
  end
    
  module ClassMethods
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