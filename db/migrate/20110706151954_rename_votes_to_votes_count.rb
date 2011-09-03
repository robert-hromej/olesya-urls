class RenameVotesToVotesCount < ActiveRecord::Migration

  def change
    rename_column :links, :votes, :votes_count
    change_column_default :links, :votes_count, 0
    execute("DROP TRIGGER `votes_compute`;")
    execute <<__SQL
      CREATE TRIGGER `votes_compute` AFTER INSERT ON `votes`
      FOR EACH ROW BEGIN
        UPDATE links SET votes_count=(SELECT SUM(votes.kind) FROM votes where link_id=links.id) WHERE links.id = NEW.link_id;
      END;
__SQL
  end
end
