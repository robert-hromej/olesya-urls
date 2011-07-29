require 'spec_helper'

describe VoteController do

  describe "existing link" do
    before(:each) do
      # create test link
      @link = Factory(:link)
      login @user
      # simulate login from link page
      @request.env['HTTP_REFERER'] = "#{DEFAULT_HOST}link/#{@link.id}"
    end

    it "should add vote to the db" do
      lambda do
        post "create", :kind => 1, :link_id => @link.id
      end.should change(Vote, :count).by(1)
    end
  end

end
