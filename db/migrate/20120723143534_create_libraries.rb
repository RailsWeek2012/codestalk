class CreateLibraries < ActiveRecord::Migration
  def change
    create_table :libraries do |t|
      t.string :title
      t.integer :user_id
      t.timestamps
    end
  end
end
