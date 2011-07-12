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
    response.should have_selector(:a, :href=>"link_url", :content=>"link_url", :target=>"_blank")
  end

  it "should not allow votes to not registered user" do
    get :index
    response.should_not have_selector(:div, :class=>"Plus")
  end

  describe "registered user" do

    before(:each) do
      login nil
    end

    it "should allow votes to registered user" do
      get :index
      response.should have_selector(:div, :class=>"Plus")
    end

    it "should show registered user avatar" do
      get :index
      response.should have_selector(:img, :src=>"/images/no-avatar.png")
    end

  end
end