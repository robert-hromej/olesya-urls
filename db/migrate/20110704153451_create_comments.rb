class CreateComments < ActiveRecord::Migration

  def change
    create_table :comments do |t|
      t.references :user, :link
      t.string :body

      t.timestamps
    end
  end
end
