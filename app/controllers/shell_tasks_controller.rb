class ShellTasksController < ApplicationController
  def create
    @shell_task = ShellTask.run!(description: shell_task_params[:description], script: shell_task_params[:script])

    respond_to do |format|
      format.turbo_stream
    end
  end

  def update; end

  def destroy; end

  private

  def shell_task_params
    params.require(:shell_task).permit(:description, :script)
  end
end
