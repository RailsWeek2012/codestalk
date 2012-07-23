class CreateLibraries < ActiveRecord::Migration
  def change
    create_table :libraries do |t|
      t.string :title
      t.string :user_id
      t.string :integer

      t.timestamps
    end
  end
end
