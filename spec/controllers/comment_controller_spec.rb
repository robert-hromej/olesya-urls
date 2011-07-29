require 'spec_helper'

describe CommentController do

  describe "existing link" do
    before(:each) do
      # create test link
      @link = Factory(:link)
      login @user
      # simulate login from link page
      @request.env['HTTP_REFERER'] = "#{DEFAULT_HOST}link/#{@link.id}"
      end

    it "should create comment" do
      # send 'new comment' form
      post "create", :comment => @comment_attr, :link_id => @link.id
      # we must see new link on list
      response.body.should have_html_tag('a', :href => "#{DEFAULT_HOST}link/#{@link.id}")
    end


  end



end
