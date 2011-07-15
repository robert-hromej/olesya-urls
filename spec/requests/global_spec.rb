require "spec_helper"

describe "IntegrationTesting", :js => true do

  before(:all) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.start
    integration_login
  end

  describe "registered" do

    before(:each) do
      visit root_path
      click_link 'twitter_login_but'
    end

    it 'should have link to show all page' do
      visit root_path
      page.should have_selector('a', :content => I18n.t(:all_links))
    end

    it "should add link" do
      create_link(:title=>'new_link_title', :url=>'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully')
      page.html.should have_html_tag('span', :content=>'Link successfully added')
    end

    it "should not add the same link twice" do
      create_link(:title=>'new_link_title', :url=>'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully')
      create_link(:test=>false, :title=>'new_link_title', :url=>'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully')
      page.html.should have_html_tag('span', :content=>' Link with such URL is already added. You can comment it or give you vote ')
    end
    it "should not add invalid or unavailable link" do
      create_link(:title=>'unavailable_link_title', :url=>'unavailable_link.com')
      page.html.should_not have_html_tag(:a, :class=>'title_link', :content=>'unavailable_link_title', :print=>false)
    end

    it "should be available fore voting" do
      create_link(:title=>'new_link_title', :url=>'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully')
      page.find('input.Plus').click
      page.html.should have_html_tag(:span, :class=>'VotesCountId\d+', :content=>'1')
      create_link(:title=>'google', :url=>'google.com')
      page.find('input.Minus').click
      page.html.should have_html_tag(:span, :class=>'VotesCountId\d+', :content=>'-1')
    end

    it "should have comments page and user can add one" do
      visit root_path
      click_link 'new_link_title'
      page.should have_selector("#no_comments_message")
      fill_in "comment_body", :with => 'this_is a new comment'
      click_button "comment_submit"
      page.should have_selector("div.comment_col")
    end

    it "should have paginator when comments count raises 5" do
      create_link(:title=>'new_link_title', :url=>'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully')
      click_link 'new_link_title'
      6.times do |n|
        fill_in "comment_body", :with => "this_is a new comment N#{n+1}"
        click_button "comment_submit"
      end
      page.should have_selector("a[href*=page]")
    end
    it "should be able to twit link" do
      create_link(:title=>'google', :url=>'google.com')
      click_link 'google'
      click_link 'tweet_this_link'
#      page.html.should have_html_tag(:textarea, :id=>'body',:content=>'google http//:.*',:print=>true)
      data = rand(10000).to_s+'test'
      fill_in 'body', :with => data
      click_button 'Tweet'
#      page.html.should have_html_tag(:span, :content=>' Message successfuly posted ',:print => true)
      visit "http://twitter.com/#{TWITTER_CREDENTIALS[:login]}"
      page.html.should have_html_tag(:span, :class=>'entry-content',:content=>"#{data}",:print=>false)
    end
  end
end