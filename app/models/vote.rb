# Link's vote. After adding new vote special trigger is performed, which recalculate votes sum and
# stores this value in 'votes_count' field. Verifies uniqueness of vote for user and link
class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :link

  validates :user_id, :presence => true
  validates :link_id, :presence => true

  # every user can vote only once per one link.
  validates_uniqueness_of :link_id, :scope => :user_id

  # user can vote 'good' or 'bad' for link. 'good' vote is a +1 point, 'bad' is -1 point.
  validates :kind, :inclusion => [-1, 1], :presence => true
end
