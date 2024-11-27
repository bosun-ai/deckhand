class ShellTasksChannel < ApplicationCable::Channel
  def subscribed
    stream_for :shell_tasks
  end
end
