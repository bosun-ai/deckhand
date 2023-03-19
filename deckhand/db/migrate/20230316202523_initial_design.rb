class InitialDesign < ActiveRecord::Migration[7.0]
  def change
    create_table :codebases do |t|
      t.string :name
      t.string :url
    end

    create_table :tasks do |t|
      t.string :description
      t.string :outputs
      t.string :inputs
    
      t.timestamps
    end
    
  end
end
