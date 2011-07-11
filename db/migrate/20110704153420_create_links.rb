class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.references :user
      t.string :title
      t.string :url
      t.integer :votes
      t.integer :comments

      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end
