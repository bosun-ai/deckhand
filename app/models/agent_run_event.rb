class AgentRunEvent < ApplicationRecord
  belongs_to :agent_run

  belongs_to :parent_event, class_name: 'AgentRunEvent', optional: true
  has_many :child_events, class_name: 'AgentRunEvent', foreign_key: 'parent_event_id', dependent: :destroy

  # after_create_commit -> { broadcast_prepend_to "agent_run_events" }

  before_validation :set_agent_run_ids

  def self.timestamp(time)
    time.to_i * (10**(9-1)) + time.nsec
  end

  def event_hash=(event)
    self.event = event
  end

  def deserialized_event
    event || {}
  end

  def type
    deserialized_event['type']
  end

  def content
    deserialized_event['content']
  end

  def new_agent
    return unless type == 'run_agent'

    AgentRun.find_by(id: content) || AgentRun.find_by(integer_id: content)
  end

  def agent_runs
    AgentRun.where(id: agent_run_ids)
  end

  private

  def set_agent_run_ids
    self.agent_run_ids = agent_run.ancestor_ids + [agent_run_id]
  end
end
