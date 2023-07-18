class AutonomousAssignment < ApplicationRecord
  belongs_to :codebase
  has_many :events, class_name: "AutonomousAssignmentEvent", dependent: :destroy

  def self.run(klass, codebase, **kwargs)
    instance = create!(codebase: codebase, name: klass.name)

    klass.run(codebase, **kwargs) do |event|
      instance.events.create!(event_hash: event)
    end
  end
end
