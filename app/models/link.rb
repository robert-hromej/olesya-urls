require "uri"
require "net/http"
require "net/https"
require 'timeout'

# Main entity - Link. Contains title, url and creator user reference. Calculating votes and comments count is performed
# by MySQL triggers, which are called after vote or comment record creating.
class Link < ActiveRecord::Base
  belongs_to :user
  has_many :comments, :dependent => :delete_all
  has_many :votes, :dependent => :delete_all

  validates :title, :presence => true, :length => {:maximum => 255}
  validates :url, :presence => true, :length => {:maximum => 255}, :uniqueness => true
  validates :user_id, :presence => true

  scope :full_links, includes([:user, :votes]).joins(:user)

  scope :all_links, full_links.order("links.created_at DESC")

  scope :popular_links, full_links.order("votes_count DESC").limit(20)

  scope :new_links, all_links.limit(20)

  scope :by_id, lambda { |id|
    all_links.where(:id => id)
  }

  scope :by_url, lambda { |url|
    where(:url => url)
  }

  #wrapper around calculated field "voted"
  def voted?(current_user = nil)
    return false if current_user.nil?
    self.votes.each do |v|
      if v.user.id == current_user.id
        return true
      end
    end
    return false
  end

  def self.valid_url?(url)
    uri = URI.parse(url)

    if url.include?('https')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
    else
      response = Net::HTTP.start(uri.host, uri.port) { |http| http.head('/') }
    end

    return [Net::HTTPSuccess, Net::HTTPRedirection].include?(response.class.superclass)
  rescue => e
    return false
  end

end
