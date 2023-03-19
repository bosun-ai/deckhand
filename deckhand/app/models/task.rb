class Task < ApplicationRecord
  include Task::Runnable

  def self.run!(description:, script:)
    task = create!(description: description, script: script)
    task.run
    task
  end
end