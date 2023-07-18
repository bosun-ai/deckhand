module Deckhand::Tools
  class ToolError < StandardError
  end

  class Tool
    include Deckhand::Lm

    attr_accessor :arguments, :context

    def self.run(arguments, context: nil)
      @cache ||= {}
      return @cache[arguments] if @cache[arguments]

      tool = new(arguments, context: context)
      tool.infer_arguments()

      serialized_args = JSON.dump(tool.arguments)
      return @cache[serialized_args] if @cache[serialized_args]

      result = tool.run()
      @cache[serialized_args] = result
      @cache[arguments] = result
      result
    end

    def infer_arguments
      reformatted = Deckhand::Tasks::ReformatAnswer.new(
        "You are using tool #{self.class.name}`, what arguments will you give it?",
        arguments,
        "json",
        example: { tool_name: self.class.name, arguments: self.class.arguments_shape}.to_json
      ).run

      begin
        @arguments = JSON.parse(reformatted)["arguments"]
      rescue => e
        raise ToolError.new("The arguments you gave for tool #{self.class.name} are not in the correct format.")
      end

      if @arguments.class != self.class.arguments_shape.class
        raise ToolError.new("The arguments you gave for tool #{self.class.name} are not in the correct format.")
      end
    end

    def initialize(arguments, context: nil)
      @arguments = arguments
      @context = context
    end

    def path_prefix
      context&.codebase&.path
    end
  end
end