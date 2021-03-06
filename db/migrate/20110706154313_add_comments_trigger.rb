class AddCommentsTrigger < ActiveRecord::Migration
  def self.up
    rename_column :links, :comments, :comments_count
    change_column_default :links, :comments_count, 0
    execute <<__SQL
      CREATE TRIGGER `comments_compute` AFTER INSERT ON `comments`
      FOR EACH ROW BEGIN
        UPDATE links SET comments_count=(SELECT COUNT(comments.id) FROM comments WHERE link_id = links.id) WHERE links.id = NEW.link_id;
      END;
__SQL
  end

  def self.down
    rename_column :links, :comments_count, :comments
    change_column_default :links, :comments, nil
    execute("DROP TRIGGER `comments_compute`;")
  end
end
