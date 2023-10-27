class ShellTask < ApplicationRecord
  include ShellTask::Runnable

  def self.run!(description:, script:, &callback)
    shell_task = create!(description:, script:)
    tail = nil
    output_stream_id = "shell_task_#{shell_task.id}_output"
    shell_task.run do |message|
      if line = message[:line]
        shell_task.broadcast_append_to 'shell_tasks',
                                       partial: 'shell_tasks/output',
                                       target: output_stream_id,
                                       locals: {
                                         output: line
                                       }
      end
      callback[message] if callback
    end
    shell_task
  end

  broadcasts_to ->(_shell_task) { :shell_tasks }, inserts_by: :prepend
end
