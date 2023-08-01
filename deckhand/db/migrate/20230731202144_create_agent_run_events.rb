class CreateAgentRunEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_run_events do |t|
      t.string :event

      t.references :agent_run, null: false, foreign_key: true
      t.string :agent_run_ids, default: '[]'

      t.timestamps
    end

    add_column :agent_runs, :parent_ids, :string, default: '[]'
  end
end
