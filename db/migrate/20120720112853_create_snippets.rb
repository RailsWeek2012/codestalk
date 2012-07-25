class CreateSnippets < ActiveRecord::Migration
  def change
    create_table :snippets do |t|
      t.string :title
      t.text :description
      t.integer :package_id
      t.string :language_id
      t.text :source
      t.timestamps
    end
  end
end
