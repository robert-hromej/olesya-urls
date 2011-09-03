class CreateVotes < ActiveRecord::Migration

  def change
    create_table :votes do |t|
      t.references :user, :link
      t.integer :kind

      t.timestamps
    end
    add_index :votes, [:user_id, :link_id], :unique => true
  end
end
