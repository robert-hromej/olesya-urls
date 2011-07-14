# main functional controller. contain functionality for creating new links, displaying, voting and tweeting them.
# all method requires authorization, except list and show
class LinkController < ApplicationController
  before_filter :is_logged?, :except => [:list, :show]

    # creates new link. Allows create only unique links, if user try to create link which is already created
    # he will be redirected onto page of that link, with promt to comment or vote for that
  def create
    #todo comment
    link_url = params[:new_link_url]
    unless (/^https?:\/{2}/i === link_url)
      link_url = "http://" + link_url
    end

    link = Link.where(:url => link_url).first

    if link
      push_notice_message t(:link_already_added)
    else
      link = Link.new(:title => params[:new_link_title],
                      :url => link_url,
                      :user => current_user)
      if Link.valid_url?(link_url) and link.save()
        push_notice_message t(:link_added)
      else
        push_notice_message t(:link_is_not_valid)
      end
    end

    respond_to do |format|
      format.html {
        if link.id == nil
          redirect_to root_path
        else
          redirect_to "/link/show/#{link.id}"
        end
      }
      format.js {
        render :update do |page|
          if link.id == nil
            page.replace_html "system_message", system_messages
          else
            page.call "redirect_to", "/link/show/#{link.id}"
          end
        end
      }
    end
  end

    # show all page
    # show all links using pagination with 20 links per page
  def list
    @links = Link.select("links.*").join_voted_field(current_user).join_users.
        order("created_at DESC").paginate(:page => params[:page], :per_page => 20)
  end

    # link page
  def show
    @link = Link.select("links.*").join_voted_field(current_user).join_users.
        where({:id => params[:id]}).order("created_at DESC").first

    raise t(:not_such_link) if @link.blank?

    @comments = Comment.where({:link_id => @link.id}).includes(:user).
        order("created_at desc").paginate(:page => params[:page], :per_page => 5)
    @comment = Comment.new(:link_id => @link.id) if current_user != nil
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html "comments", :partial => "comments"
          page << "matroska('all_comments');observe_element('paginator');"
        end
      }
    end
  rescue StandardError => e
    push_notice_message e
    redirect_to root_url
  end

    # ajax method for performing voting. User can vote 'good' or 'bad' for link. 'good' vote is a +1 point, 'bad' is -1 point.
    # every user can vote only once per one link. Takes to url params 'link_id' and 'kind'. Cleans cache fragments for
    # this link, to force rails update votes count on link's partial
  def vote
    link = Link.find(params[:link_id])

    vote = Vote.new
    vote.link = link
    vote.user = current_user
    vote.kind = params[:kind].to_i

    raise t(:already_voted) if !vote.save

    link.reload

    respond_to do |format|
      format.html { redirect_to :back }
      format.js {
        render :update do |page|
          page.replace_html "VoteArrowsId#{link.id}", ""
          page.replace_html "VotesCountId#{link.id}", link.votes_count
        end
      }
    end
    expire_fragment(%r{link_id_#{link.id}_author_id_\d*_voted_\d*})

  rescue StandardError => e
    push_error_message e

    respond_to do |format|
      format.html { redirect_to :back }
      format.js {
        render :update do |page|
          page.replace_html "system_message", system_messages
        end
      }
    end
  end

    # ajax post method for creating comments. Use form fields values on link page ('show'). Cleans cache fragments for
    # this link, to force rails update comments count on link's partial
  def comment
    raise t(:link_not_found) if Link.where(:id => params[:comment][:link_id]).first == nil

    params[:comment][:user_id] = current_user.id
    comment = Comment.create(params[:comment])
    controller = self

    respond_to do |format|
      format.html { redirect_to :back }
      format.js {
        render :update do |page|
          if comment.valid?
            page.call "add_comment", comment.id, render(:partial => "comment", :locals => {:comment => comment})
            page.replace_html "LinkCommentCountId#{comment.link_id}", comment.link.comments_count
          else
            controller.push_error_message t(:comment_not_valid)
            page.replace_html "system_message", system_messages
          end
        end
      }
    end
    expire_fragment(%r{link_id_#{comment.link_id}_author_id_\d*_voted_\d*})
  rescue StandardError => e
    push_error_message e
    respond_to do |format|
      format.html { redirect_to :back }
      format.js {
        render :update do |page|
          page.replace_html "system_message", system_messages
        end
      }
    end
  end


    # ajax method for showing 'twitt this'. It generates default message - link title and bit.ly short url for link's one.
  def twitt_this
    render :update do |page|
      begin
        raise t(:link_id_not_specific) if !params[:id]
        link = Link.find(params[:id])
        raise t(:link_not_found) if link.blank?

        begin
          url = Net::HTTP.get(URI.parse(get_bit_ly_api_url(link.url)))
        rescue StandardError => e
          logger.error("Bitly error: #{e} \n #{e.backtrace.join("\n")}")
          raise t(:bitly_error)
        end

        body = "#{link.title} #{url}"

        page.hide :twitt_this_link
        page.replace_html :twitt_this, :partial => "twitt_this", :locals => {:body => body}
        page.show :twitt_this

      rescue StandardError => e
        push_error_message e.to_s
        page.replace_html :system_message, system_messages
      end
    end
  end

  private

  def previous_url
    request.nil? ? '/' : request.env['HTTP_REFERER']
  end

  def get_bit_ly_api_url url
    return "http://api.bit.ly/v3/shorten?login=#{APP_CONFIG[:bitly][:login]}&apiKey=#{APP_CONFIG[:bitly][:api_key]}&longUrl=#{CGI::escape(url)}&format=txt"
  end

end
