class CreateVotes < ActiveRecord::Migration

  def self.up
    create_table :votes do |t|
      t.references :user, :link
      t.integer :kind

      t.timestamps
    end
    add_index :votes, [:user_id, :link_id], :unique => true
  end

  def self.down
    remove_index :votes, :column => [:user_id, :link_id]
    drop_table :votes
  end

end
