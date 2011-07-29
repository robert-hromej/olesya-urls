class CommentController < ApplicationController
  before_filter :is_logged?

  def create
   # Uses form fields values on link page ('show').
    raise t(:link_not_found) if Link.find(params[:comment][:link_id]) == nil

    params[:comment][:user_id] = current_user.id

    comment = Comment.create(params[:comment])
    controller = self

    respond_to do |format|
      format.html { redirect_to :back }
      format.js {
        render :update do |page|
          if comment.valid?
            page.call "add_comment", comment.id, render(:partial => "link/comment", :locals => {:comment => comment})
            page.call "replace_html", "LinkCommentCountId#{comment.link_id}", comment.link.comments_count
          else
            controller.push_error_message t(:comment_not_valid)
            page.call "system_message", system_messages
          end
        end
      }
    end

    #Cleans cache fragments for this link, to force rails update comments count on link's partial
    expire_fragment(%r{link_id_#{comment.link_id}_author_id_\d*_voted_\d*})
  rescue StandardError => e
    push_error_message e
    respond_to do |format|
      format.html { redirect_to :back }
      format.js {
        render :update do |page|
          page.call "system_message", system_messages
        end
      }
    end
  end

  def index
  end

end
