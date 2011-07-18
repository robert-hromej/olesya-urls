ActiveRecord::Base.connection.execute("DROP TRIGGER if exists comments_compute");
ActiveRecord::Base.connection.execute <<__SQL
  CREATE TRIGGER `comments_compute` AFTER INSERT ON `comments`
  FOR EACH ROW BEGIN
    UPDATE links SET comments_count=(SELECT COUNT(comments.id) FROM comments WHERE link_id = links.id) WHERE links.id = NEW.link_id;
  END;
__SQL

ActiveRecord::Base.connection.execute("DROP TRIGGER if exists votes_compute");
ActiveRecord::Base.connection.execute <<__SQL
  CREATE TRIGGER `votes_compute` AFTER INSERT ON `votes`
  FOR EACH ROW BEGIN
    UPDATE links SET votes_count=(SELECT SUM(votes.kind) FROM votes where link_id=links.id) WHERE links.id = NEW.link_id;
  END;
__SQL