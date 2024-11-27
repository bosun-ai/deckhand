class ChangeAgentRunOutputToJsonb < ActiveRecord::Migration[7.1]
  def change
    change_column :agent_runs, :output, :jsonb, using: "output::jsonb"
  end
end
