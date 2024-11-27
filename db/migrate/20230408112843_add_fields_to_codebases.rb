class AddFieldsToCodebases < ActiveRecord::Migration[7.0]
  def change
    add_column :codebases, :checked_out, :boolean, default: false
    add_column :codebases, :name_slug, :string
    add_index :codebases, :name_slug, unique: true
  end
end
