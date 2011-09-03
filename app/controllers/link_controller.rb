# main functional controller. contain functionality for creating new links, displaying, voting and tweeting them.
# all method requires authorization, except list and show
class LinkController < ApplicationController
  before_filter :is_logged?, :except => [:index, :show]

  # creates new link.
  def create
    # add 'http://' to url if it isn't
    link_url = params[:new_link_url]
    unless (/^https?:\/{2}/i === link_url)
      link_url = "http://" + link_url
    end

    # Allows create only unique links
    @link = Link.by_url(link_url).first

    if @link
      #if user try to create link which is already created
      push_notice_message t(:link_already_added)
    else
      # save new link
      @link = Link.new(:title => params[:new_link_title],
                       :url => link_url,
                       :user => current_user)

      if Link.valid_url?(link_url) and @link.save()
        push_notice_message t(:link_added)
      else
        push_notice_message t(:link_is_not_valid)
      end
    end

    respond_to do |format|
      format.js
      format.html {
        redirect_to (@link.id ? link_path(@link.id) : root_path)
      }
    end
  end

  # show all page
  def index
    # show all links using pagination with 20 links per page
    @links = Link.all_links(current_user).paginate(:page => params[:page], :per_page => 20)
  end

  # link page
  def show
    @link = Link.by_id(params[:id]).first

    raise t(:not_such_link) if @link.blank?

    @comments = Comment.by_link_id(@link.id).paginate(:page => params[:page], :per_page => 5)
    @comment = Comment.new(:link_id => @link.id) if current_user != nil
  rescue StandardError => e
    push_notice_message e.message
    redirect_to root_url
  end

end
