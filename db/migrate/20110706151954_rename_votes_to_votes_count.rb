class RenameVotesToVotesCount < ActiveRecord::Migration
  def self.up
    rename_column :links, :votes, :votes_count
    change_column_default :links, :votes_count, 0
    execute("DROP TRIGGER `votes_compute`;")
    execute("CREATE TRIGGER `votes_compute` AFTER INSERT ON `votes` FOR EACH ROW BEGIN  update links set votes_count=(SELECT sum(votes.kind) FROM votes where link_id=links.id) where links.id=NEW.link_id; END;")
  end

  def self.down
    rename_column :links, :votes_count, :votes
    change_column_default :links, :votes_count, nil
    execute("DROP TRIGGER `votes_compute`;")
    execute("CREATE TRIGGER `votes_compute` AFTER INSERT ON `votes` FOR EACH ROW BEGIN  update links set votes=(SELECT sum(votes.kind) FROM votes where link_id=links.id) where links.id=NEW.link_id; END;")
  end
end
