require "spec_helper"

describe HomeController do

  before(:each) do
    # create test link
    @link = Factory(:link, :url => "link_url", :title => "link_title")
  end

  render_views

  it "should not fail" do
    # move to front page
    get :index
    response.should be_success
  end

  it "should have link on" do
    # move to front page
    get :index
    # we must see link
    response.body.should have_html_tag(:a, :content => @link.title)
  end

  it "should not allow votes to not registered user" do
    # move to front page
    get :index
    # we don't see voting arrows if aren't login
    response.body.should_not have_html_tag(:input, :class => 'Plus')
    response.body.should_not have_html_tag(:input, :class => 'Minus')
  end

  # for registered users
  describe "registered user" do

    before(:each) do
      # registered user must login
      login nil
    end

    it "should allow votes to registered user", :request => true do
      # move to front page
      get :index
      # Arrows for voting has classes Plus and Minus
      response.body.should have_html_tag(:input, :class => 'Plus')
      response.body.should have_html_tag(:input, :class => 'Minus')
    end

    it "should show registered user avatar" do
      # move to front page
      get :index
      # if user has no avatar - display special avatar
      response.body.should have_html_tag(:img, :src => "/assets/no-avatar.png")
    end

  end

end