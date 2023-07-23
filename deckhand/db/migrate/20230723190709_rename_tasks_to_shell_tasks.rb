class RenameTasksToShellTasks < ActiveRecord::Migration[7.0]
  def change
    rename_table "tasks", "shell_tasks"
  end
end
