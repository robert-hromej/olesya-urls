class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :link
  validates_presence_of :body

  validates :body, :presence => true, :length => {:maximum => 255}
  validates :link_id, :presence => true
  validates :user_id, :presence => true
end
