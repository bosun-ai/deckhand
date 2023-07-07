module Deckhand::Tasks
  class Task
    include Deckhand::Lm

    attr_accessor :context, :tools, :question

    def initialize(question, context: Deckhand::Context.new, tools: all_tools)
      @question = question
      @tools = tools
      @context = context
    end

    def context_prompt
      if context.blank?
        ""
      else
        %Q{You are given the following context to the question:
          
#{context.join("\n\n").indent(2)}
  
}
      end
    end

    def self.run(question, context: [], tools: all_tools)
      task = new(question, context: context, tools: tools)
      task.run()
    end

    def run
      raise "Not implemented"
    end
  end
end