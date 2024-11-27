module Deckhand
  class Context
    attr_accessor :history, :assignment

    def initialize(assignment, history: [])
      self.assignment = assignment
      self.history = history
    end

    def add_history(type:, content:)
      event = { type:, content: }
      history << { type:, content: }
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
        .filter { |h| %i[observation information conclusion].include? h[:type] }
    end

    def summarize_knowledge
      knowledge.map { |h| h[:content] }.join("\n\n")
    end

    def as_json(*_options)
      {
        assignment:,
        history:
      }
    end

    def to_json(*options)
      JSON.dump(as_json(*options))
    end

    def deep_dup
      dup.tap do |context|
        context.assignment = assignment.deep_dup
        context.history = history.deep_dup
      end
    end
  end
end
