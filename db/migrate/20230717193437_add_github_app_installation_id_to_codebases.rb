class AddGithubAppInstallationIdToCodebases < ActiveRecord::Migration[7.0]
  def change
    add_column :codebases, :github_app_installation_id, :string
    add_column :codebases, :github_app_issue_id, :string
  end
end
