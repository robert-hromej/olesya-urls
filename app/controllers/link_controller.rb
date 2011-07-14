# main functional controller. contain functionality for creating new links, displaying, voting and tweeting them.
# all method requires authorization, except list and show
class LinkController < ApplicationController
  before_filter :is_logged?, :except => [:list, :show]

  # creates new link. Allows create only unique links, if user try to create link which is already created
  # he will be redirected onto page of that link, with promt to comment or vote for that
  def create

    link_url = params[:new_link_url]
    unless (/^https?:\/{2}/i === link_url)
      link_url = "http://" + link_url
    end

    link = Link.where(:url => link_url).first

    if link
      push_notice_message "Link with such URL is already added. You can comment it or give you vote"
      js_for_respond = "window.location='/link/show/#{link.id}'"
      html_for_respond = comment_path(:id=>link.id)
    else
      require "uri"
      unless (link_url.include?('https'))
        begin
          require "net/http"
          url = URI.parse(link_url)
          res = Net::HTTP.start(url.host, url.port) { |http| http.get('/') }
          code = res.code
        rescue => e
          logger.error("HTTP: #{e} \n #{e.backtrace.join("\n")}")
        end
      else
        begin
          require "net/https"
          url = URI.parse(link_url)
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          request = Net::HTTP::Get.new(url.request_uri)
          response = http.request(request)
          code = response.code
        rescue => e
          logger.error("HTTPS: #{e} \n #{e.backtrace.join("\n")}")
        end
      end

      if /[23](\d){2}/i === code
        link = Link.new(:title => params[:new_link_title],
                        :url => link_url,
                        :user => current_user)


        if link.save()
          push_notice_message "Link successfully added"
          js_for_respond = "window.location='/link/show/#{link.id}'"
          html_for_respond = comment_path(:id=>link.id)
        else
          js_for_respond = "show_message('Link is not added',false)"
          html_for_respond = previous_url
        end
      else
        js_for_respond = "show_message('Link is not valid',true)"
        html_for_respond = previous_url
      end
    end
    respond_to do |format|
      format.html {
        push_notice_message('Link is not added')
        redirect_to(html_for_respond) }
      format.js {
        render :update do |page|
          page << "#{js_for_respond};"
        end
      }
    end
  end

  # show all page, show all links using pagination with 20 links per page
  def list
    @links = Link.select("links.*").join_voted_field(current_user).join_users.order("created_at DESC").paginate(:page => params[:page], :per_page => 20)
  end

  # link page
  def show
    @link = Link.select("links.*").join_voted_field(current_user).join_users.where({:id => params[:id]}).order("created_at DESC").first

    raise "There is no such link, but you can add it." if @link.blank?

    @comments = Comment.find_all_by_link_id(@link.id, :include => :user, :order=>'created_at desc').paginate(:page=>params[:page], :per_page=>5)
    @comment = Comment.new(:link_id => @link.id, :user_id => current_user.id) if current_user != nil
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

    raise "Already voted" if !vote.save

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
    # test link
    link = Link.find(params[:comment][:link_id])

    params[:comment][:user_id] = current_user.id
    comment = Comment.create(params[:comment])

    respond_to do |format|
      format.html { redirect_to :back }
      format.js {
        render :update do |page|
          page << "add_comment('#{comment.id}','#{comment.body.gsub("\n", " ")}','#{comment.user.profile_image}','#{comment.created_at.strftime("%d %B %Y")}','#{comment.user.screen_name}');"
          page.replace_html "LinkCommentCountId#{comment.link_id}", link_to("Comments #{comment.link.comments_count}", comment_path(:id=>comment.link_id))
        end
      }
    end
    expire_fragment(%r{link_id_#{comment.link_id}_author_id_\d*_voted_\d*})
    #redirect_to :back

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
        raise "link id not specific" if !params[:id]
        link = Link.find(params[:id])
        raise "link not found" if link.blank?

        begin
          url = Net::HTTP.get(URI.parse("http://api.bit.ly/v3/shorten?login=#{APP_CONFIG[:bitly][:login]}&apiKey=#{APP_CONFIG[:bitly][:api_key]}&longUrl=#{CGI::escape(link.url)}&format=txt"))
        rescue StandardError => e
          logger.error("Bitly error: #{e} \n #{e.backtrace.join("\n")}")
          raise "bitly error"
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

end
