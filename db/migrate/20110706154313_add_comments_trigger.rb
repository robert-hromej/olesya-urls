class AddCommentsTrigger < ActiveRecord::Migration
  def self.up
    rename_column :links, :comments, :comments_count
    change_column_default :links, :comments_count, 0
    execute("CREATE TRIGGER `comments_compute` AFTER INSERT ON `comments` FOR EACH ROW BEGIN  update links set comments_count=(SELECT count(comments.id) FROM comments where link_id=links.id) where links.id=NEW.link_id; END;")
  end

  def self.down
    rename_column :links, :comments_count, :comments
    change_column_default :links, :comments, nil
    execute("DROP TRIGGER `comments_compute`;")
  end
end
