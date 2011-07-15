require "spec_helper"
describe HomeController do

  before(:each) do
    @link = Factory(:link, :url=>"link_url", :title=>"link_title")
  end

  render_views

  it "should not fail" do
    get :index
    response.should be_success
  end

  it "should have link on" do
    get :index
    response.body.should  have_html_tag(:a,:content=>'link_title')
  end

  it "should not allow votes to not registered user" do
    get :index
    response.body.should_not have_html_tag(:div,:class=>'Plus')
  end

  describe "registered user" do

    before(:each) do
      login nil
    end

    it "should allow votes to registered user",:request => true do
      get :index
      response.body.should have_html_tag(:div,:class=>'Plus')
    end

    it "should show registered user avatar" do
      get :index
      response.body.should have_html_tag(:img, :src=>"/images/no-avatar.png")
    end

  end
end