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

  def retry!(checkpoint)
    checkpoint = checkpoint.to_s
    update! states: states.entries.take_while {|c,_| c != checkpoint}.to_h
    resume
  end

  def deserialize_agent
    agents = ApplicationAgent.descendants
    parent_agent = parent&.deserialize_agent
    agent_context = ApplicationAgent::Context.from_json(context)
    # TODO what type is context? it should be an ApplicationContext but it seems like it might not be
    agent = agents.find {|a| a.name == name }.new(**arguments.merge(context: agent_context, parent: parent_agent))
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

  private

  def ensure_parent_ids
    return if !parent_id || !parent_ids.blank?
    self.parent_ids = parent.parent_ids + [parent_id]
  end
end
