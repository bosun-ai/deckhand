class InitialDesign < ActiveRecord::Migration[7.0]
  def change
    create_table :codebases do |t|
      t.string :name
      t.string :url
      t.timestamps
    end

    create_table :tasks do |t|
      t.string :description
      t.string :script

      t.timestamp :started_at
      t.timestamp :finished_at

      t.integer :exit_code

      t.timestamps
    end
  end
end
