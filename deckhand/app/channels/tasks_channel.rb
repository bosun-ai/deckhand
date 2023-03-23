class TasksChannel < ApplicationCable::Channel
  def subscribed
    stream_for :tasks
  end
end