class CreateSnippets < ActiveRecord::Migration
  def change
    create_table :snippets do |t|
      t.integer :library_id
      t.string :title
      t.text :description
      t.string :language_id
      t.text :source
      t.timestamps
    end
  end
end
