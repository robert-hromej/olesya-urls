class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :link

  validates :user_id, :presence => true
  validates :link_id, :presence => true
  validates_uniqueness_of :link_id, :scope => :user_id
  validates :kind, :inclusion => [-1, 1], :presence => true
end
