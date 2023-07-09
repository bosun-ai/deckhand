class AutonomousAssignmentEvent < ApplicationRecord
  belongs_to :autonomous_assignment

  alias_attribute :assignment, :autonomous_assignment

  after_create_commit -> { broadcast_prepend_to "autonomous_assignment_events" }

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
