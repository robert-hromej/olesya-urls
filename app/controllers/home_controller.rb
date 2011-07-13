# This controller contain the front page of web application, where top 20 popular links and top 20 recent links
# are showed
class HomeController < ApplicationController

  # loads links from DB
  def index
    @popular_links = Link.select("links.*").join_voted_field(current_user).join_users.order("votes_count DESC").limit(20)
    @new_links = Link.select("links.*").join_voted_field(current_user).join_users.order("updated_at DESC").limit(20)
  end

end
