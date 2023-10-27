class AgentRunEvent < ApplicationRecord
  belongs_to :agent_run

  # after_create_commit -> { broadcast_prepend_to "agent_run_events" }

  before_validation :set_agent_run_ids

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

    AgentRun.find(content)
  end

  private

  def set_agent_run_ids
    self.agent_run_ids = agent_run.parent_ids + [agent_run_id]
  end
end
