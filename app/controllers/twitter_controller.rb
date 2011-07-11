class TwitterController < ApplicationController
  before_filter :is_logged?, :except => [:login, :logout, :after_login]

  def login
    callback_url = "http://#{request.host_with_port}/twitter/after_login"

    request_token = twitter_oauth.get_request_token(:oauth_callback => callback_url)

    session['rtoken'] = request_token.token
    session['rsecret'] = request_token.secret

    redirect_to "https://api.twitter.com/oauth/authenticate?oauth_token=#{request_token.token}"
  rescue OAuth::Error => e
    logger.error("OAuth error: #{e} \n #{e.backtrace.join("\n")}")
    push_error_message "Sorry, but OAuth error occurred"
    redirect_to "/"
  end

  def logout
    set_current_user(nil)
    redirect_to "/"
  end

  def after_login
    raise "You deny access to Twitter" if params[:denied]

    result = OAuth::RequestToken.new(twitter_oauth, session['rtoken'], session['rsecret']).get_access_token(:oauth_verifier => params[:oauth_verifier])

    options = {:consumer_key => APP_CONFIG[:twitter][:consumer_token],
               :consumer_secret => APP_CONFIG[:twitter][:consumer_secret],
               :oauth_token => result.token,
               :oauth_token_secret => result.secret}

    client = Twitter::Client.new(options)
    credentials = client.verify_credentials

    user = User.where(:screen_name => credentials.screen_name).first
    user = User.create(:screen_name => credentials.screen_name, :oauth_token => result.token, :oauth_secret => result.secret) if user == nil

    user.update_avatar
    expire_fragment(%r{link_id_\d*_author_id_#{user.id}_voted_\d*})

    set_current_user user

    redirect_to "/"

  rescue OAuth::Error => e
    logger.error("OAuth error: #{e} \n #{e.backtrace.join("\n")}")
    push_error_message "Sorry, but OAuth error occurred"
    redirect_to "/"
  rescue Twitter::Error => e
    logger.error("Twitter error: #{e} \n #{e.backtrace.join("\n")}")
    push_error_message "Sorry, but Twitter error occurred"
    redirect_to "/"
  rescue StandardError => e
    push_error_message e.to_s
    redirect_to "/"
  end

  def twitt
    message = params[:body]
    user = current_user

    controller = self

    render :update do |page|
      begin
        raise "Message length must be less or equal then 140" if message.blank? or message.size >= 140

        user.client.update(message)

        controller.push_notice_message "Message successfuly posted"
        page.replace_html :system_message, system_messages

        page.show :twitt_this_link
        page.hide :twitt_this

      rescue Twitter::Forbidden => e
        # status is dublicated
        controller.push_error_message "Bitly error: " + e.to_s
        page.replace_html :system_message, system_messages
      rescue Twitter::Error => e
        logger.error("Twitter error: #{e} \n #{e.backtrace.join("\n")}")
          #page.replace_html :notice, "Sorry, but Twitter error occurred"
        controller.push_error_message "Sorry, but Twitter error occurred"
        page.replace_html :system_message, system_messages
      rescue StandardError => e
        controller.push_error_message e.to_s
        page.replace_html :system_message, system_messages
      end
    end
  end

  private

  def twitter_oauth
    options = {
        :site => "https://api.twitter.com",
        :request_endpoint => "https://api.twitter.com"
    }
    OAuth::Consumer.new(APP_CONFIG[:twitter][:consumer_token], APP_CONFIG[:twitter][:consumer_secret], options)
  end

end
