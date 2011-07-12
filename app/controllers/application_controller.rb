class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    @current_user ||= User.find(session[:current_user_id]) if session[:current_user_id]
  end

  def set_current_user(user)
    @current_user = user
    session[:current_user_id] = (user ? user.id : nil)
  end

  def authorized?
    !!current_user
  end

  def push_notice_message(msg)
    session[:system_message] ||= {:notice => [], :error => []}
    session[:system_message][:notice] << msg
  end

  def push_error_message(msg)
    session[:system_message] ||= {:notice => [], :error => []}
    session[:system_message][:error] << msg
  end

  private

  def is_logged?
    if current_user.blank?
      respond_to do |format|
        format.html {
          redirect_to :controller => :twitter, :action => :login
        }
        format.js {
          push_notice_message "Please login first"
          render :update do |page|
            page.replace_html "system_message", system_messages
          end
        }
      end
    end
  end

end
