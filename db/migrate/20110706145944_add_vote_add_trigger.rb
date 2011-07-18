class AddVoteAddTrigger < ActiveRecord::Migration
  def self.up
    execute <<__SQL
      CREATE TRIGGER `votes_compute` AFTER INSERT ON `votes`
      FOR EACH ROW BEGIN
        UPDATE links SET votes=(SELECT SUM(votes.kind) FROM votes WHERE link_id = links.id) WHERE links.id = NEW.link_id;
      END;
__SQL
  end

  def self.down
    execute("DROP TRIGGER `votes_compute`;")
  end
end
