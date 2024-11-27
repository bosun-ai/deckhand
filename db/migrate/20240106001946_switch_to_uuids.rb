class SwitchToUuids < ActiveRecord::Migration[7.1]
  def up
    enable_extension 'pgcrypto'

    rename_column :agent_runs, :parent_ids, :ancestor_ids # just for clarity

    add_column :agent_runs, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_column :agent_runs, :parent_uuid, :uuid
    add_column :agent_runs, :ancestor_uuids, :uuid, array: true, default: [], null: false

    AgentRun.find_each do |run|
      run.update(parent_uuid: run.parent&.uuid, ancestor_uuids: run.ancestors.pluck(:uuid))
    end

    change_table :agent_run_events, bulk: true do |t|
      t.column :uuid, :uuid, default: 'gen_random_uuid()', null: false
      t.column :agent_run_uuid, :uuid
      t.column :agent_run_uuids, :uuid, array: true
    end

    AgentRunEvent.find_each do |event|
      event.update(agent_run_uuid: event.agent_run.uuid, agent_run_uuids: event.agent_runs.pluck(:uuid))
    end
 
    change_table :agent_run_events do |t|
      t.rename :id, :integer_id
      t.rename :agent_run_id, :agent_run_integer_id
      t.rename :agent_run_ids, :agent_run_integer_ids
    end

    change_table :agent_run_events do |t|
      t.rename :uuid, :id
      t.rename :agent_run_uuid, :agent_run_id
      t.rename :agent_run_uuids, :agent_run_ids

      t.remove :integer_id
      t.remove :agent_run_integer_id
      t.remove :agent_run_integer_ids
    end

    change_table :agent_runs do |t|
      t.remove :parent_id
      t.remove :ancestor_ids
      t.rename :parent_uuid, :parent_id
      t.rename :ancestor_uuids, :ancestor_ids

      t.rename :id, :integer_id
      t.rename :uuid, :id
    end


    execute <<-SQL
      ALTER TABLE agent_runs DROP CONSTRAINT agent_runs_pkey;
      ALTER TABLE agent_runs ADD PRIMARY KEY (id);
      ALTER TABLE agent_run_events ADD PRIMARY KEY (id);
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
