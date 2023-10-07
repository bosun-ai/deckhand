class AddDescriptionToCodebase < ActiveRecord::Migration[7.0]
  def change
    add_column :codebases, :description, :string
  end
end
