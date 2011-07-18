# This is the base class for other controllers in project. Here is implemented management for logged in user.
# The current_user method allows getting current user from session, if user logged in.
# The is_logged? method allows check user authorization and perform login if it was not.
# push_notice_message and push_error_message allows add messages into special section in layout.
class ApplicationController < ActionController::Base
  protect_from_forgery

    # finds current user record in table 'users' using id stored in session
  def current_user
    @current_user ||= User.find(session[:current_user_id]) if session[:current_user_id]
  end

    # save user id in session
  def set_current_user(user)
    @current_user = user
    session[:current_user_id] = (user ? user.id : nil)
  end

  def authorized?
    !!current_user
  end

    # add notice message, which will be printed in layout with green color
  def push_notice_message(msg)
    push_message(:notice, msg)
  end

    # add error message, which will be printed in layout with red color
  def push_error_message(msg)
    push_message(:error, msg)
  end

    # add message
  def push_message(type, msg)
    session[:system_message] ||= {:notice => [], :error => []}
    session[:system_message][type] << msg
  end

  private

    # can be used in 'before_filter' to verify user authorization
  def is_logged?
    if current_user.blank?
      respond_to do |format|
        format.html {
          redirect_to :controller => :twitter, :action => :login
        }
        format.js {
          push_notice_message t(:please_login)
          render :update do |page|
            page.call "system_message", system_messages
          end
        }
      end
    end
  end

end
