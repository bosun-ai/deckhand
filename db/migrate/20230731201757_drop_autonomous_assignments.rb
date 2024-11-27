class DropAutonomousAssignments < ActiveRecord::Migration[7.0]
  def change
    drop_table :autonomous_assignment_events
    drop_table :autonomous_assignments
  end
end
