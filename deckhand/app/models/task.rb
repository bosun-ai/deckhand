class Task < ApplicationRecord
  include Task::Runnable

  def self.run!(description:, script:)
    task = create!(description: description, script: script)
    Thread.new do
      output_stream_id = "task_#{task.id}_output"
      Async do
        task.run 
      end
      Async do
        task.tail do |line|
          Rails.logger.info "Broadcasting line: #{line}" 
          task.broadcast_append_to "tasks", target: output_stream_id, text: line
        end
      end
    end.join
    task
  end

  broadcasts_to ->(task) { :tasks }, inserts_by: :prepend
end