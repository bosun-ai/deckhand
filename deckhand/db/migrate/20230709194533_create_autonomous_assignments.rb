class CreateAutonomousAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :autonomous_assignments do |t|
      t.string :name
      t.string :arguments
      t.references :codebase, null: false, foreign_key: true

      t.timestamps
    end
  end
end
