class AddVoteAddTrigger < ActiveRecord::Migration
  def self.up
    execute("CREATE TRIGGER `votes_compute` AFTER INSERT ON `votes` FOR EACH ROW BEGIN  update links set votes=(SELECT sum(votes.kind) FROM votes where link_id=links.id) where links.id=NEW.link_id; END;")
  end

  def self.down
    execute("DROP TRIGGER `votes_compute`;")
  end
end
