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

  scope :full_links, lambda { |current_user| select("links.*").join_voted_field(current_user).joins(:user) }
  scope :all_links, lambda { |current_user| full_links(current_user).order("created_at DESC") }
  scope :popular_links, lambda { |current_user| full_links(current_user).order("votes_count DESC").includes(:user).limit(20) }
  scope :new_links, lambda { |current_user| all_links(current_user).includes(:user).limit(20) }
  scope :by_id, lambda { |id, current_user| all_links(current_user).where(:id => id) }
  scope :by_url, lambda { |url| where(:url => url) }

  def self.join_voted_field(current_user)
    select("(v.id IS NOT NULL) voted").
        joins("LEFT JOIN votes v ON (v.link_id = links.id and v.user_id = #{(current_user ? current_user.id : 0)})")
  end

  #wrapper around calculated field "voted"
  def voted?
    self.voted.to_i != 0
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
