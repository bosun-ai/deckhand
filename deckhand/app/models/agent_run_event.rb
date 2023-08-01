class AgentRunEvent < ApplicationRecord
  belongs_to :agent_run

  after_create_commit -> { broadcast_prepend_to "agent_run_events" }

  def event_hash=(event)
    self.event = JSON.dump(event)
  end

  def deserialized_event
    @deserialized_event ||= JSON.parse(event)
  end

  def type
    deserialized_event["type"]
  end

  def content
    deserialized_event["content"]
  end
end
