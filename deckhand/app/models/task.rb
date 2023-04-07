class Task < ApplicationRecord
  include Task::Runnable

  def self.run!(description:, script:)
    task = create!(description: description, script: script)
    tail = nil
    output_stream_id = "task_#{task.id}_output"
    task.run do |message|
      if line = message[:line]
        task.broadcast_append_to "tasks",
          partial: 'tasks/output',
          target: output_stream_id,
          locals: {
            output: line
          }
      end
    end
    task
  end

  broadcasts_to ->(task) { :tasks }, inserts_by: :prepend
end