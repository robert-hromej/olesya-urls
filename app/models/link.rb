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

  def self.join_users
    joins("INNER JOIN users u ON u.id = links.user_id")
  end

  def self.join_voted_field(current_user)
    select("(v.id IS NOT NULL) voted").
        joins("LEFT JOIN votes v ON (v.link_id = links.id and v.user_id = #{(current_user ? current_user.id : 0)})")
  end

  def voted?
    return (self.voted.to_i == 1)
  end

  def self.valid_url? url
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
    code = response.code

      # todo maybe exists more elegant way to check status code?
    return (/[23](\d){2}/i === code)

  rescue => e
    logger.error("HTTP/HTTPS: #{e} \n #{e.backtrace.join("\n")}")
    return false
  end

end
