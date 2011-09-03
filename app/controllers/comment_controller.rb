class CommentController < ApplicationController
  before_filter :is_logged?

  def create
    begin
      # Uses form fields values on link page ('show').
      raise t(:link_not_found) if Link.find(params[:comment][:link_id]) == nil

      params[:comment][:user_id] = current_user.id

      @comment = Comment.create(params[:comment])

      unless @comment.valid?
        push_error_message t(:comment_not_valid)
      end

      #Cleans cache fragments for this link, to force rails update comments count on link's partial
      expire_fragment(%r{link_id_#{@comment.link_id}_author_id_\d*_voted_\d*})
    rescue StandardError => e
      @error = e.message
      push_error_message @error
    end

    respond_to do |format|
      format.html {
        if @error.blank?
          redirect_to link_path(@comment.link_id)
        else
          redirect_to :back
        end
      }
      format.js
    end

  end

end
