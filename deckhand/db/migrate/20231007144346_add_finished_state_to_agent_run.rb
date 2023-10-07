class AddFinishedStateToAgentRun < ActiveRecord::Migration[7.0]
  def change
    add_column :agent_runs, :error, :string
  end
end
