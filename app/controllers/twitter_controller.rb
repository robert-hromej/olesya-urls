# This class aggregate all functionality for working with Twitter API. Twitter login and tweeting are implemented here.
# all methods requires authorization, except ones for for authorization
class TwitterController < ApplicationController

  before_filter :is_logged?, :except => [:login, :logout, :after_login]

  TWITTER_API_URL = "https://api.twitter.com"

    # perform first step in oauth authenticating - get request token and redirect to Twitter's authenticating page
  def login
    request_token = twitter_oauth.get_request_token(:oauth_callback => oauth_callback)

    session['rtoken'] = request_token.token
    session['rsecret'] = request_token.secret

    redirect_to twitter_authenticate(request_token.token)
  rescue OAuth::Error => e
    logger.error("OAuth error: #{e} \n #{e.backtrace.join("\n")}")
    push_error_message t(:oauth_error)
    redirect_to root_url
  end

    # simply clean current user value in session
  def logout
    set_current_user(nil)
    redirect_to root_url
  end

    # is redirected by Twitter after authenticating. Sets current user variable. Creates record in table user for new user
    # and use exiting record for already registered users. Searching is performed by screen_name returned by Twitter.
    # Updates user profile image and cleans cache fragments
  def after_login
    raise t(:twitter_denided) if params[:denied]

    result = OAuth::RequestToken.new(twitter_oauth, session['rtoken'], session['rsecret']).
        get_access_token(:oauth_verifier => params[:oauth_verifier])

    options = {:consumer_key => APP_CONFIG[:twitter][:consumer_token],
               :consumer_secret => APP_CONFIG[:twitter][:consumer_secret],
               :oauth_token => result.token,
               :oauth_token_secret => result.secret}

    client = Twitter::Client.new(options)
    credentials = client.verify_credentials

    user = User.login(credentials, result)

    user.update_avatar
    expire_fragment(%r{link_id_\d*_author_id_#{user.id}_voted_\d*})
    expire_fragment(%r{comment_id_\d*_author_id_#{user.id}})

    set_current_user user

    redirect_to root_url

  rescue OAuth::Error => e
    logger.error("OAuth error: #{e} \n #{e.backtrace.join("\n")}")
    push_error_message t(:oauth_error)
    redirect_to root_url
  rescue Twitter::Error => e
    logger.error("Twitter error: #{e} \n #{e.backtrace.join("\n")}")
    push_error_message t(:twitter_error)
    redirect_to root_url
  rescue StandardError => e
    push_error_message e.to_s
    redirect_to root_url
  end

    # ajax method for twitting message on twitter. if twitter error occurred during process - shows it using ajax.
  def twitt
    message = params[:body]
    user = current_user
    controller = self

    render :update do |page|
      begin
        raise t(:length_message) if message.blank? or message.size >= 140

        user.client.update(message)

        controller.push_notice_message t(:message_posted)
        page.replace_html :system_message, system_messages

        page.show :twitt_this_link
        page.hide :twitt_this

      rescue Twitter::Forbidden => e
        # status is duplicated
        controller.push_error_message "Bitly error: " + e.to_s
        page.replace_html :system_message, system_messages
      rescue Twitter::Error => e
        logger.error("Twitter error: #{e} \n #{e.backtrace.join("\n")}")
          #page.replace_html :notice, t(:twitter_error)
        controller.push_error_message t(:twitter_error)
        page.replace_html :system_message, system_messages
      rescue StandardError => e
        controller.push_error_message e.to_s
        page.replace_html :system_message, system_messages
      end
    end
  end

  private

    # return OAuth::Consumer object
  def twitter_oauth
    OAuth::Consumer.new(APP_CONFIG[:twitter][:consumer_token], APP_CONFIG[:twitter][:consumer_secret],
                        {:site => TWITTER_API_URL, :request_endpoint => TWITTER_API_URL})
  end

    # generate callback url for twitter login
  def oauth_callback
    @callback_url ||= "http://#{request.host_with_port}/twitter/after_login"
    return @callback_url
  end

  def twitter_authenticate oauth_token
    return "https://api.twitter.com/oauth/authenticate?oauth_token=#{oauth_token}"
  end

end
