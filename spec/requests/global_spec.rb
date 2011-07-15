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
      visit root_path
      page.should have_selector('a#add_link')
      click_link 'add_link'
      fill_in 'new_link_title', :with=>'new_link_title'
      fill_in 'new_link_url', :with => 'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully'
      click_button 'Create'
      page.should have_selector('span', :content => I18n.t(:link_added))
    end

    it "should not add the same link twice" do
      visit root_path
      page.should have_selector('a#add_link')
      click_link 'add_link'
      fill_in 'new_link_title', :with => 'new_link_title'
      fill_in 'new_link_url', :with => 'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully'
      click_button 'Create'
      page.should have_selector('span', :content => I18n.t(:link_already_added))
    end

    it "should be available fore voting up" do
      visit root_path
      page.find('input.Plus').click
      page.should have_selector('span[class*=VotesCountId]', :content => '1')
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
      visit root_path
      click_link 'new_link_title'
      6.times do |n|
        fill_in "comment_body", :with => "this_is a new comment N#{n+1}"
        click_button "comment_submit"
      end
      page.should have_selector("a[href*=page]")
    end

  end
end