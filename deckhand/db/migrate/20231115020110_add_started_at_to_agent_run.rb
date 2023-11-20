class AddStartedAtToAgentRun < ActiveRecord::Migration[7.1]
  def change
    add_column :agent_runs, :started_at, :datetime
    AgentRun.all.each do |ar|
      ar.update! started_at: ar.created_at
    end
  end
end
