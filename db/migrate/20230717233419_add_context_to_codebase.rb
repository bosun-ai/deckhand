class AddContextToCodebase < ActiveRecord::Migration[7.0]
  def change
    add_column :codebases, :context, :string
  end
end
