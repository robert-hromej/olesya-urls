# This controller contain the front page of web application, where top 20 popular links and top 20 recent links
# are showed
class HomeController < ApplicationController

  # load links from DB
  def index
    @popular_links = Link.popular_links(current_user)
    @new_links = Link.new_links(current_user)
  end

end
