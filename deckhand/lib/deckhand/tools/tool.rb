module Deckhand::Tools
  class Tool
    include Deckhand::Lm

    attr_accessor :arguments

    def self.run(arguments)
      tool = new(arguments)
      tool.infer_arguments()
      tool.run()
    end

    def infer_arguments
      reformatted = Deckhand::Tasks::ReformatAnswer.new(
        "You are using tool #{self.class.name}`, what arguments will you give it?",
        arguments,
        "json",
        example: { tool_name: self.class.name, arguments: self.class.arguments_shape}.to_json
      ).run
      @arguments = JSON.parse(reformatted)["arguments"]
    end

    def initialize(arguments)
      @arguments = arguments
    end
  end
end