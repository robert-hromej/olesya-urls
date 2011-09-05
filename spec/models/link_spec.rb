require "spec_helper"

describe "LinkModel" do

  before(:each) do
    # create default link
    @attr = {:user_id => 1, :title => "title", :url => "http://sample.com/"}
  end

  it "should be valid with write parameters" do
    link = Link.new(@attr)
    link.should be_valid
  end

  it "should have correct title" do
    link = Link.new(@attr.merge(:title => ""))
    link.should_not be_valid
  end

  it "should have correct url" do
    link = Link.new(@attr.merge(:url => ""))
    link.should_not be_valid
  end

  describe "created link" do

    before(:each) do
      @link = Link.create!(@attr)
    end

    it "should have uniq url" do
      link = Link.new(@attr)
      link.should_not be_valid
    end

    it "should belong to user" do
      @link.should respond_to(:user)
    end

    it "should have comments" do
      @link.should respond_to(:comments)
    end

  end
end
# == Schema Information
#
# Table name: links
#
#  id             :integer         not null, primary key
#  user_id        :integer
#  title          :string(255)
#  url            :string(255)
#  votes_count    :integer         default(0)
#  comments_count :integer         default(0)
#  created_at     :datetime
#  updated_at     :datetime
#

