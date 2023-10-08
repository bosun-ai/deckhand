class AutonomousAgent::Context
  include ActiveSupport::Callbacks
  define_callbacks :add_history

  attr_accessor :history, :assignment

  def initialize(assignment, history: [])
    self.assignment = assignment
    self.history = history.map do |entry|
      entry.deep_symbolize_keys!
      entry[:type] = entry[:type].to_sym
      entry
    end
  end

  def add_history(type:, content:)
    run_callbacks :add_history do
      event = { type: type, content: content }
      history << { type: type, content: content }
      history
    end
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
      .filter { |h| [:observation, :information, :conclusion].include? h[:type] }
  end

  def summarize_knowledge
    knowledge.map { |h| h[:content] }.join("\n\n")
  end

  def as_json(*options)
    instance_variables.map do |name|
      [name[1..-1].to_sym, instance_variable_get(name)]
    end.to_h
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
