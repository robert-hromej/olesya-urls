require "spec_helper"
describe "link" do
  before(:each) do
    @attr = {:user_id=>1, :title=>"title", :url=>"http://sample.com/"}
  end
  it "should be valid with write parameters" do
    link = Link.new(@attr)
    link.should be_valid
  end
  it "should have correct title" do
    link = Link.new(@attr.merge(:title=>""))
    link.should_not be_valid
  end
  it "should have correct url" do
    link = Link.new(@attr.merge(:url=>""))
    link.should_not be_valid
  end
  describe "created link" do
    before(:each) do
      @link=Link.create!(@attr)
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