class MainDeckController < ApplicationController
  def show
    @codebases = Codebase.all
    @tasks = Task.all
    @new_task = Task.new
  end
end
