class AddAgentState < ActiveRecord::Migration[7.1]
  def change
    add_column :agent_runs, :states, :jsonb, default: {}
  end
end
