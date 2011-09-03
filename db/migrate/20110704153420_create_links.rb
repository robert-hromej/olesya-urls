class CreateLinks < ActiveRecord::Migration

  def change
    create_table :links do |t|
      t.references :user
      t.string :title
      t.string :url
      t.integer :votes
      t.integer :comments

      t.timestamps
    end
  end
end
