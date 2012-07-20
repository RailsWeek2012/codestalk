class CreateSnippets < ActiveRecord::Migration
  def change
    create_table :snippets do |t|
      t.string :library
      t.string :title
      t.text :description
      t.string :language
      t.text :source

      t.timestamps
    end
  end
end
