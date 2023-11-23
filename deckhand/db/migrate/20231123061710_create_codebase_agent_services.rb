class CreateCodebaseAgentServices < ActiveRecord::Migration[7.1]
  def change
    create_table :codebase_agent_services do |t|
      t.references :codebase, null: false, foreign_key: true
      t.jsonb :configuration, null: false, default: {}
      t.jsonb :state, null: false, default: {}
      t.boolean :enabled, null: false, default: false
      t.string :name

      t.timestamps
    end
  end
end
