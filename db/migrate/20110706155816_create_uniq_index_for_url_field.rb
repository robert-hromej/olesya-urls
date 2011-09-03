class CreateUniqIndexForUrlField < ActiveRecord::Migration

  def change
    Link.transaction do
      Link.find_by_sql("SELECT l.url, count(l.id) s FROM links l GROUP BY l.url HAVING s > 1 ORDER BY s DESC ").each do |l|
        Link.find_by_sql("SELECT l.* FROM links l WHERE l.url = '#{l.url}' LIMIT 1, #{l.s-1}").each do |link|
          link.destroy
        end
      end
    end
    add_index :links, :url, :unique => true
  end
end
