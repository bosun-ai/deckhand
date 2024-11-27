class CreateAutonomousAssignmentEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :autonomous_assignment_events do |t|
      t.references :autonomous_assignment, null: false, foreign_key: true
      t.string :event

      t.timestamps
    end
  end
end
