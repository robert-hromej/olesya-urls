class LinkController < ApplicationController
  before_filter :is_logged?, :except => [:list, :show]

    # after create link
  def create
    link_url = params[:new_link_url]
    if (!link_url.include?("http://") && !link_url.include?("https://"))
      link_url = "http://" + link_url
    end

    link = Link.where(:url => link_url).first

    if link
      push_notice_message "Link with such URL is already added. You can comment it or give you vote"
      redirect_to :action => :show, :id => link.id
      return
    end

    link = Link.new
    link.title = params[:new_link_title]
    link.url = link_url
    link.user = current_user
    link.save

    if link.save
      push_notice_message "Link successfully added"
      redirect_to :action => :show, :id => link.id
    else
      push_notice_message "Link not added"
      redirect_to :action => :list
    end
  end

    # show all
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

    # perform vote
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

    # comment
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

    #
    # show ajax form for twitt this
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

end
