require "spec_helper"

# todo COMMENTS!
describe "CommentModel" do

  before(:each) do
    @attr={:user_id => 1, :link_id => 1, :body=>'Lorem ipsum dolor sit amet'}
  end

  it "should be valid with write parameters" do
    comment = Comment.new(@attr)
    comment.should be_valid
  end

  it "should have valid body" do
    comment = Comment.new(@attr.merge(:body=>""))
    comment.should_not be_valid
  end

  describe "created comment" do

    before(:each) do
      @comment = Comment.create!(@attr)
    end

    it "should belong to link" do
      @comment.should respond_to(:link)
    end

    it "should belong to user" do
      @comment.should respond_to(:user)
    end

  end
end