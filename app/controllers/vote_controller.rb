class VoteController < ApplicationController
  before_filter :is_logged?

  def create
    # Takes to url params 'id' and 'kind'.
    link = Link.find(params[:link_id])

    vote = Vote.new
    vote.link = link
    vote.user = current_user
    vote.kind = params[:kind].to_i

    # every user can vote only once per one link.
    raise t(:already_voted) if !vote.save

    # reload link from table to see new votes count
    link.reload

    respond_to do |format|
      format.html { redirect_to :back }
      format.js {
        render :update do |page|
          page.call "vote", link.id, link.votes_count
        end
      }
    end
    # Cleans cache fragments for this link, to force rails update votes count on link's partial
    expire_fragment(%r{link_id_#{link.id}_author_id_\d*_voted_\d*})

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

end
