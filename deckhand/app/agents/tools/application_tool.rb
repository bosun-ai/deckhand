class ApplicationTool < AutonomousAgent::Tool
  arguments context: nil

  module Cached
    def run
      cached { super }
    end
  end

  def self.inherited(subclass)
    subclass.prepend Cached
  end

  def self.all_tools
    # TODO: possibly eagerly load all tools in the parent directory
    descendants
  end

  def cached(&block)
    self.class.cached(self, &block)
  end

  def self.cached(tool, &block)
    @cache ||= {}
    serialized_args = JSON.dump(tool.arguments)
    if @cache[serialized_args]
      Rails.logger.debug "Using cached result for #{name} with args #{serialized_args}"
      return @cache[serialized_args]
    end

    result = block.call
    @cache[serialized_args] = result
  end

  def self.arguments_shape
    {}
  end

  def self.parameters
    {
      type: :object,
      properties: {},
      required: []
    }
  end

  def self.usage
    "#{name} <arguments>, for example: #{example}"
  end

  def self.example
    "#{name} #{arguments_shape.to_json}"
  end

  def self.openai_signature
    {
      name:,
      description:,
      parameters:
    }
  end

  def infer_arguments
    reformatted = run(ReformatAnswerAgent,
                      "You are using tool #{self.class.name}`, what arguments will you give it?",
                      arguments,
                      'json',
                      example: { tool_name: self.class.name, arguments: self.class.arguments_shape }.to_json)

    begin
      @arguments = JSON.parse(reformatted)['arguments']
    rescue StandardError => e
      raise Error, "The arguments you gave for tool #{self.class.name} are not in the correct format."
    end

    return unless @arguments.class != self.class.arguments_shape.class

    raise Error, "The arguments you gave for tool #{self.class.name} are not in the correct format."
  end

  def path_prefix
    context&.codebase&.path || '/'
  end

  class Error < StandardError
  end
end
