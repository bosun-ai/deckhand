class CreateGithubAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :github_access_tokens do |t|
      t.references :codebase, null: false, foreign_key: true
      t.string :token

      t.timestamps
    end
  end
end
