# User entity. Contains logic for getting twitter profile image using screen_name and creates Twitter::Client object
# using user's oauth token and secret.
class User < ActiveRecord::Base
  has_many :comments, :dependent => :delete_all
  has_many :links, :dependent => :delete_all
  has_many :votes, :dependent => :delete_all

  validates :screen_name, :uniqueness => true, :presence => true, :length => {:maximum => 255}
  validates :oauth_secret, :presence => true
  validates :oauth_token, :presence => true

    # stores end profile image url in DB
  def update_avatar
    self.avatar_url = client.profile_image(self.screen_name, :size => 'normal')
    self.save
  end

    # return url for profile image
  def profile_image(user = nil)
    return (self.avatar_url ? self.avatar_url : "/images/no-avatar.png")
  end

    # generate twitter's url for getting profile image using screen name
  def profile_url
    "http://twitter.com/#{self.screen_name}"
  end

    # searches user using screen name or create new one with specific oauth token and secret
  def self.login(credentials, result)
    # use exiting record for already registered users
    u = User.where(:screen_name => credentials.screen_name).first
    # Creates record in table user for new user
    u ||= User.create(:screen_name => credentials.screen_name, :oauth_token => result.token, :oauth_secret => result.secret)
  end

    # create complete Twitter::Client object for working with twitter under specific user account
  def client
    options = {
        :consumer_key => APP_CONFIG[:twitter][:consumer_token],
        :consumer_secret => APP_CONFIG[:twitter][:consumer_secret],
        :oauth_token => self.oauth_token,
        :oauth_token_secret => self.oauth_secret
    }
    Twitter::Client.new(options)
  end

end
