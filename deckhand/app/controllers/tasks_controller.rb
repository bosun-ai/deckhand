class TasksController < ApplicationController
  def create
    @task = Task.run!(description: task_params[:description], script: task_params[:script])

    respond_to do |format|
      format.turbo_stream
    end
  end

  def update
  end

  def destroy
  end

  private

  def task_params
    params.require(:task).permit(:description, :script)
  end
end
