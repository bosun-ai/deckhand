class CreateAgentRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_runs do |t|
      t.string :name
      t.string :arguments
      t.string :context
      t.string :output
      t.timestamp :finished_at
      t.references :parent, null: true, foreign_key: { to_table: :agent_runs }

      t.timestamps
    end
  end
end
