# Link's text comment. After adding new comment special trigger is performed, which recalculate comments count and
# stores this value in 'comments_count' field.
class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :link
  validates_presence_of :body

  validates :body, :presence => true, :length => {:maximum => 255}
  validates :link_id, :presence => true
  validates :user_id, :presence => true

  scope :by_link_id, lambda { |link_id|
    where(:link_id => link_id).includes(:user).order("created_at desc")
  }

end

# == Schema Information
#
# Table name: comments
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  link_id    :integer
#  body       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

