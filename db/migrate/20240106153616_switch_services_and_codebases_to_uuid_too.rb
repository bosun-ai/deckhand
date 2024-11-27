class SwitchServicesAndCodebasesToUuidToo < ActiveRecord::Migration[7.1]
  def up
    add_column :codebase_agent_services, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_column :codebases, :uuid, :uuid, default: 'gen_random_uuid()', null: false

    add_column :codebase_agent_services, :codebase_uuid, :uuid
    add_column :agent_runs, :codebase_agent_service_uuid, :uuid

    CodebaseAgentService.find_each do |service|
      service.update(codebase_uuid: service.codebase.uuid)
      service.agent_runs.update_all(codebase_agent_service_uuid: service.uuid)
    end

    change_table :codebase_agent_services do |t|
      t.rename :id, :integer_id
      t.rename :uuid, :id

      t.remove :codebase_id
      t.rename :codebase_uuid, :codebase_id

      t.remove :integer_id
    end

    add_column :github_access_tokens, :codebase_uuid, :uuid

    GithubAccessToken.find_each do |token|
      token.update(codebase_uuid: token.codebase.uuid)
    end

    change_table :github_access_tokens do |t|
      t.remove :codebase_id
      t.rename :codebase_uuid, :codebase_id
    end

    change_table :codebases do |t|
      t.rename :id, :integer_id
      t.rename :uuid, :id
    end

    change_table :agent_runs do |t|
      t.remove :codebase_agent_service_id
      t.rename :codebase_agent_service_uuid, :codebase_agent_service_id
    end

    execute <<-SQL
      ALTER TABLE codebase_agent_services ADD PRIMARY KEY (id);
      ALTER TABLE codebases DROP CONSTRAINT codebases_pkey;
      ALTER TABLE codebases ADD PRIMARY KEY (id);
    SQL
  end
end
