class AgentRun < ApplicationRecord
  belongs_to :parent, optional: true, class_name: 'AgentRun'
  belongs_to :codebase_agent_service, optional: true

  has_many :children, class_name: 'AgentRun', foreign_key: 'parent_id', dependent: :destroy
  has_many :events, class_name: 'AgentRunEvent', dependent: :destroy

  before_validation :ensure_parent_ids

  State = Struct.new(
    :checkpoint,
    :value,
    :async_status,
    :error
  ) do
    def value_available?
      # HACK: using in band signalling to fix broken parent value availability checking system
      agent_run = if value.is_a?(Hash) && value["states"]
                    AgentRun.new(**value)
                  elsif value.is_a? AgentRun
                    value
                  end

      return agent_run.finished? if agent_run

      return async_status.to_s == 'ready' if async?

      !failed?
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
      self.async_status = 'failed' if async?
      error
    end

    def completed!(value)
      self.value = value
      self.error = nil
      self.async_status = 'ready' if async?
    end

    def waiting!
      self.async_status = 'waiting'
    end

    def waiting?
      async_status == 'waiting'
    end
  end

  def self.for_codebase(codebase)
    where("context->>'codebase_id' = ?", codebase.id.to_s)
  end

  def self.root
    where(parent: nil)
  end

  def state
    states.values.last&.then { |s| State.new(**s) }
  end

  def has_state?(checkpoint_name)
    states.has_key?(checkpoint_name)
  end

  def get_state(checkpoint_name)
    states[checkpoint_name]&.then { |s| State.new(**s) }
  end

  def queued?
    state&.queued?
  end

  def finished?
    !!finished_at
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
    state.async_status = 'error' if state.async?
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
    async_status = 'ready' if state.async?

    transition_to!(checkpoint, value, async_status: async_status)
  end

  # when checkpoint is set to nil, retry from scratch
  def retry!(checkpoint=false)
    reset_to_checkpoint!(checkpoint) if checkpoint != false
    resume
  end

  def reset_to_checkpoint!(checkpoint)
    old_states = states
    reset
    if checkpoint
      checkpoint = checkpoint.to_s
      self.states = old_states.entries.take_while { |c, _| c != checkpoint}.to_h
    end
    save!
  end

  def reset
    self.states = {}
    self.output = nil
    self.error = nil
    self.finished_at = nil
    self.started_at = nil
  end

  def reset_to_agent_run!(agent_run)
    # TODO: this finding of the agent run is a bit fragile. Would be better
    # if agent runs had an explicit identifying value.
    checkpoint = states.find do |cp, state|
      cp.include?('run_agent') && state['value']['id'] == agent_run.id
    end&.first

    raise "No checkpoint found for AgentRun #{agent_run.id} on AgentRun #{id}" unless checkpoint

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
    agent = agent_class.new(**arguments.merge(context: agent_context, parent: parent_agent, parent_checkpoint: parent_checkpoint))
    agent.agent_run = self
    agent
  end

  def resume
    deserialize_agent.run
  end

  def success?
    finished? && error.blank?
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
    return if !parent_id || parent_ids.present?

    self.parent_ids = parent.parent_ids + [parent_id]
  end
end
