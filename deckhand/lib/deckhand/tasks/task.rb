module Deckhand::Tasks
  class Task
    include Deckhand::Lm

    attr_accessor :context, :tools, :question

    def initialize(question, context: nil, tools: Deckhand::Lm.all_tools)
      @question = question
      @tools = tools
      @context = context || Deckhand::Context.new(question)
    end

    def context_prompt
      if context.blank?
        ""
      else
        %Q{You are given the following context to the question:
          
#{context.summarize_knowledge.indent(2)}
  
}
      end
    end

    def self.run(question, context: nil, tools: Deckhand::Lm.all_tools)
      task = new(question, context: context, tools: tools)
      task.run()
    end

    def run
      raise "Not implemented"
    end
  end
end