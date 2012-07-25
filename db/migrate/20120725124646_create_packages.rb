class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :title
      t.text :description
      t.integer :project_id
      t.integer :user_id
      t.timestamps
    end
  end
end
