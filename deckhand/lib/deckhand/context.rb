module Deckhand
  class Context
    attr_accessor :history, :assignment, :event_callback

    def initialize(assignment, event_callback: nil)
      self.assignment = assignment
      self.history = []
      self.event_callback = event_callback
    end

    def add_history(type:, content: )
      event = { type: type, content: content}
      history << { type: type, content: content}
      event_callback.call(event) if event_callback
      history
    end

    def add_observation(observation)
      add_history type: :observation, content: observation
    end

    def add_theory(theory)
      add_history type: :theory, content: theory
    end

    def add_information(information)
      add_history type: :information, content: information
    end

    def add_conclusion(conclusion)
      add_history type: :conclusion, content: conclusion
    end

    def knowledge
      history
        .filter {|h| [:observation, :information, :conclusion].include? h[:type] }
    end

    def summarize_knowledge
      knowledge.map {|h| h[:content] }.join("\n\n")
    end

    def deep_dup
      dup.tap do |context|
        context.assignment = assignment.deep_dup
        context.history = history.deep_dup
      end
    end
  end
end