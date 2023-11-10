class AgentRun < ApplicationRecord
  belongs_to :parent, optional: true, class_name: 'AgentRun'
  has_many :children, class_name: 'AgentRun', foreign_key: 'parent_id', dependent: :destroy
  has_many :events, class_name: "AgentRunEvent", dependent: :destroy

  before_validation :ensure_parent_ids

  class State < Struct.new(
    :checkpoint,
    :value,
    :async_status
  )
    def value_available?
      !async?|| async_status.to_s == 'ready'
    end

    def queued?
      async_status.to_s == 'queued'
    end

    def async?
      async_status
    end
  end

  def self.for_codebase(codebase)
   where("context->>'codebase_id' = ?", codebase.id.to_s)
  end

  def self.root
    where(parent: nil)
  end

  def state
    states.values.last&.yield_self {|s| State.new(**s) }
  end

  def has_state?(checkpoint_name)
    states.has_key?(checkpoint_name)
  end
  
  def get_state(checkpoint_name)
    states[checkpoint_name]&.yield_self {|s| State.new(**s) }
  end

  def transition_to(checkpoint, value, async_status: nil)
    states[checkpoint] = State.new(
      checkpoint:,
      value:,
      async_status:,
    ).as_json
  end

  def transition_to!(checkpoint, value, async_status: nil)
    transition_to(checkpoint, value, async_status:)
    save!
  end

  def retry!(checkpoint=nil)
    self.states = if checkpoint
      checkpoint = checkpoint.to_s
      states.entries.take_while {|c,_| c != checkpoint}.to_h
    else
      {}
    end
    self.output = nil
    self.error = nil
    self.finished_at = nil
    save!
    resume
  end

  def agent_class
    if Rails.env.development?
      name.constantize
    else
      agents = ApplicationAgent.descendants
      agents.find {|a| a.name == name }
    end
  end

  def deserialize_agent
    parent_agent = parent&.deserialize_agent
    agent_context = ApplicationAgent::Context.from_json(context)
    agent_class = self.agent_class
    puts "agent_class: #{agent_class.inspect}"
    # TODO what type is context? it should be an ApplicationContext but it seems like it might not be
    agent = agent_class.new(**arguments.merge(context: agent_context, parent: parent_agent))
    agent.agent_run = self
    agent
  end

  def resume
    deserialize_agent.run
  end

  def success?
    finished_at && error.blank?
  end

  def duration
    ActiveSupport::Duration.build(finished_at - created_at)
  end

  def error=(error)
    error = {
      class: error.class.name,
      message: error.message,
      backtrace: error.backtrace
    }.as_json if error && error.is_a?(Exception)
    super(error)
  end

  def feed
    children.sort_by(&:created_at).reverse
  end

  def output
    if agent_class.respond_to? :parse_output
      agent_class.parse_output(attributes['output'])
    else
      attributes['output']
    end
  end

  private

  def ensure_parent_ids
    return if !parent_id || !parent_ids.blank?
    self.parent_ids = parent.parent_ids + [parent_id]
  end
end
