class AgentRun < ApplicationRecord
  belongs_to :parent, optional: true, class_name: 'AgentRun'
  has_many :children, class_name: 'AgentRun', foreign_key: 'parent_id', dependent: :destroy
  has_many :events, class_name: "AgentRunEvent", dependent: :destroy

  before_validation :ensure_parent_ids

  class State < Struct.new(
    :checkpoint,
    :value,
    :async_status,
    :error
  )
    def value_available?
      # HACK using in band signalling to fix broken parent value availability checking system
      if value.is_a?(Hash) && value["states"]
        agent_run = AgentRun.new(**value)
        return agent_run.state.value_available?
      end

      if async?
        async_status.to_s == 'ready'
      else
        !failed?
      end
    end

    def queued?
      async_status.to_s == 'queued'
    end

    def async?
      !!async_status
    end

    def failed?
      !!error
    end

    def failed!(error)
      self.error = error
      if async?
        self.async_status = 'failed'
      end
      error
    end

    def completed!(value)
      self.value = value
      self.error = nil
      if async?
        self.async_status = 'ready'
      end
    end

    def waiting!
      self.async_status = 'waiting'
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

  def queued?
    state&.queued?
  end

  def transition_to(checkpoint, value, async_status: nil)
    states[checkpoint] = State.new(
      checkpoint:,
      value:,
      async_status:,
      error: nil
    ).as_json
  end

  def transition_to_error(checkpoint, error)
    state = get_state(checkpoint) || State.new(checkpoint: checkpoint)
    if state.async?
      state.async_status = 'error'
    end
    state.error = error
    states[checkpoint] = state
  end

  def transition_to_error!(checkpoint, error)
    transition_to_error(checkpoint, error)
    save!
  end

  def transition_to!(checkpoint, value, async_status: nil)
    Rails.logger.debug("Transitioning to #{id} #{checkpoint}: #{value.inspect} #{async_status.inspect}")
    transition_to(checkpoint, value, async_status: async_status)
    save!
  end

  def transition_to_waiting!(checkpoint)
    states[checkpoint] = states[checkpoint].merge(async_status: 'waiting')
    save!
  end

  def transition_to_completed!(checkpoint, value)
    state = get_state(checkpoint)
    async_status = if state.async?
      'ready'
    else
      nil
    end
    transition_to!(checkpoint, value, async_status: async_status)
  end

  # when checkpoint is set to nil, retry from scratch
  def retry!(checkpoint=false)
    reset_to_checkpoint!(checkpoint) if checkpoint != false
    resume
  end

  def reset_to_checkpoint!(checkpoint)
    self.states = if checkpoint
      checkpoint = checkpoint.to_s
      states.entries.take_while {|c,_| c != checkpoint}.to_h
    else
      {}
    end
    self.output = nil
    self.error = nil
    self.finished_at = nil
    self.started_at = nil
    save!
  end

  def reset_to_agent_run!(agent_run)
    # TODO this finding of the agent run is a bit fragile. Would be better
    # if agent runs had an explicit identifying value.
    checkpoint = states.find do |checkpoint, state|
      checkpoint =~ /run_agent/ && state['value']['id'] == agent_run.id
    end&.first

    raise "No checkpoint found for AgentRun #{agent_run.id} on AgentRun #{id}"

    reset_to_checkpoint!(checkpoint)
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
    ActiveSupport::Duration.build(finished_at - started_at) if finished_at && started_at
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
      agent_class.parse_output(super)
    else
      super
    end
  end

  private

  def ensure_parent_ids
    return if !parent_id || !parent_ids.blank?
    self.parent_ids = parent.parent_ids + [parent_id]
  end
end
