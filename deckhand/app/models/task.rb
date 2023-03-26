class Task < ApplicationRecord
  include Task::Runnable

  def self.run!(description:, script:)
    task = create!(description: description, script: script)
    Thread.new { task.run }.value
    task
  end

  broadcasts_to ->(task) { :tasks }, inserts_by: :prepend
end