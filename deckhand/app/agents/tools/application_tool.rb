class ApplicationTool < AutonomousAgent::Tool
  attr_accessor :arguments, :context

  set_callback :run, :around do |object, block|
    object.cached(&block)
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
    return @cache[serialized_args] if @cache[serialized_args]

    result = block.call
    @cache[serialized_args] = result
    result
  end

  def self.arguments_shape
    {}
  end

  def self.parameters
    {
      type: :object,
      properties: {},
      required: [],
    }
  end

  def self.usage
    "#{name} <arguments>, for example: #{example}"
  end

  def self.example
    "#{name} #{arguments_shape.to_json}"
  end

  def self.run(arguments, context: nil)
    tool = new(arguments, context: context)
    # tool.infer_arguments()
    tool.run
  end

  def self.openai_signature
    {
      name: name,
      description: description,
      parameters: parameters,
    }
  end

  def infer_arguments
    reformatted = ReformatAnswerAgent.new(
      "You are using tool #{self.class.name}`, what arguments will you give it?",
      arguments,
      "json",
      example: { tool_name: self.class.name, arguments: self.class.arguments_shape }.to_json,
    ).run

    begin
      @arguments = JSON.parse(reformatted)["arguments"]
    rescue => e
      raise Error.new("The arguments you gave for tool #{self.class.name} are not in the correct format.")
    end

    if @arguments.class != self.class.arguments_shape.class
      raise Error.new("The arguments you gave for tool #{self.class.name} are not in the correct format.")
    end
  end

  def initialize(arguments, context: nil)
    @arguments = arguments
    @context = context
  end

  def path_prefix
    context&.codebase&.path_prefix || '/'
  end

  class Error < StandardError
  end
end
