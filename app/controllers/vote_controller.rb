class VoteController < ApplicationController
  before_filter :is_logged?

  def create
    begin
      # Takes to url params 'id' and 'kind'.
      @link = Link.find(params[:link_id])

      vote = Vote.new
      vote.link = @link
      vote.user = current_user
      vote.kind = params[:kind].to_i

      # every user can vote only once per one link.
      raise t(:already_voted) if !vote.save

      # reload link from table to see new votes count
      @link.reload

      # Cleans cache fragments for this link, to force rails update votes count on link's partial
      expire_fragment(%r{link_id_#{@link.id}_author_id_\d*_voted_\d*})
    rescue StandardError => e
      push_error_message e.message
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

end
