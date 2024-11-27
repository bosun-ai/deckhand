class AddParentCheckpointToAgentRuns < ActiveRecord::Migration[7.1]
  def change
    add_column :agent_runs, :parent_checkpoint, :string
  end
end
