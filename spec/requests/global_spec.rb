require "spec_helper"


describe 'Global', :js => true do
  before(:all) do
    integration_login
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.start
  end
  describe "registered" do
    before(:each) do
      visit root_path
      click_link 'Sighup with Twitter'
    end
    it 'should have link to show all page' do
      visit root_path
      page.should have_selector('a', :content=>"ALL LINKS")
    end

    it "should add link" do
      visit root_path
      page.should have_selector('a#add_link')
      click_link 'add_link'
      fill_in 'new_link_title', :with=>'new_link_title'
      fill_in 'new_link_url', :with=>'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully'
      click_button 'Create'
      page.should have_selector('span',:content=>'Link successfully added')

    end

    it "should have comments page and user can add one" do
      visit root_path
      click_link 'new_link_title'
      page.should have_selector("#no_comments_message")
      fill_in "comment_body", :with => 'this_is a new comment'
      click_button "comment_submit"
      page.should have_selector("tr.comment_col")
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