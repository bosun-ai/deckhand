class AddStartedAtAndDurationToAgentRunEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :agent_run_events, :started_at, :bigint
    add_column :agent_run_events, :duration, :bigint
    add_column :agent_run_events, :parent_event_id, :uuid

    add_index :agent_run_events, :parent_event_id
  end
end
