class ChangeStringsToJsonb < ActiveRecord::Migration[7.0]
  def change
    change_column :agent_runs, :context, :jsonb, using: 'context::jsonb'
    change_column :agent_runs, :arguments, :jsonb, using: 'arguments::jsonb'
    change_column :agent_runs, :parent_ids, :string, default: nil
    change_column :agent_runs, :parent_ids, :jsonb, using: 'parent_ids::jsonb', default: []
    change_column :agent_runs, :error, :jsonb, using: 'error::jsonb'


    change_column :agent_run_events, :event, :jsonb, using: 'event::jsonb'
    change_column :agent_run_events, :agent_run_ids, :string, default: nil
    change_column :agent_run_events, :agent_run_ids, :jsonb, using: 'agent_run_ids::jsonb', default: []

    change_column :codebases, :context, :jsonb, using: 'context::jsonb'

  end
end
