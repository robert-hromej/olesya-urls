require 'spec_helper'

describe CommentController do

  describe "existing link" do

    before(:each) do
      @link = Factory(:link)
      login @user
      @request.env['HTTP_REFERER'] = "#{DEFAULT_HOST}link/#{@link.id}"
    end

    it "should create comment" do
      post "create", :comment => @comment_attr, :link_id => @link.id
      response.should redirect_to("#{DEFAULT_HOST}link/#{@link.id}")
    end

  end
end
