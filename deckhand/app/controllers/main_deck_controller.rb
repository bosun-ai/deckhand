class MainDeckController < ApplicationController
  def show
    @codebases = Codebase.all
    @shell_tasks = ShellTask.all
    @new_shell_task = ShellTask.new
  end
end
