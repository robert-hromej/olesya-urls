require "spec_helper"

# todo COMMENTS!
describe "IntegrationTesting", :js => true do

  before(:all) do
    # setup DatabaseCleaner
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.start #cleaning database
    25.times {Factory(:link,:user_id => 1, :url=>Factory.next(:url))}
    # perform twitter login
    integration_login #creates twitter session and logs out
  end

  describe "not registered user" do
    it 'should not be able to add link' do
      # open front page
      visit root_path

      click_link 'add_link_button'

      # fill 'new link' form with test values
      fill_in NEW_LINK_TITLE_FIELD, :with => 'sample link'
      fill_in NEW_LINK_URL_FIELD, :with => 'google.com'

      click_button CREATE_LINK_BUTTON

      # we must see error message
      page.html.should have_html_tag('span', :content => I18n.t(:please_login) )
    end
    it 'should see all links page with pagination' do
      visit root_path
      click_link SHOW_ALL_LINK
      page.html.should have_html_tag(:a, :class=>'next_page')
    end
  end

  describe "registered user" do

    before(:each) do
      # login with twitter
      visit root_path
      click_link LOGIN_BUTTON
    end

    it 'should have link to show all page' do
      visit root_path
      page.should have_selector('a', :content => I18n.t(:all_links))
    end

    it "should add link" do
      create_link(:title=>'new_link_title', :url=>'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully')
      # test info message after successful creation
      page.html.should have_html_tag('span', :content => I18n.t(:link_added) )
    end

    it "should not add the same link twice" do
      create_link(:title=>'new_link_title', :url=>'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully')
      create_link(:test=>false, :title=>'new_link_title', :url=>'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully')
      # test error message after failed creation
      page.html.should have_html_tag('span', :content => I18n.t(:link_already_added))
    end

    it "should not add invalid or unavailable link" do
      create_link(:title=>'unavailable_link_title', :url=>'unavailable_link.com')
      # test error message after failed creation
      page.html.should_not have_html_tag(:a, :class=>'title_link', :content=>'unavailable_link_title', :print=>false)
    end

    it "should be available fore voting" do
      create_link(:title=>'new_link_title', :url=>'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully')
      # vote 'good' for link
      page.find('input.Plus').click
      # check votes sum
      page.html.should have_html_tag(:span, :class=>'VotesCountId\d+', :content=>'1')

      create_link(:title=>'google', :url=>'google.com')
      # vote 'bad' for link
      page.find('input.Minus').click
      # check votes sum
      page.html.should have_html_tag(:span, :class=>'VotesCountId\d+', :content=>'-1')
    end

    it "should have comments page and user can add one" do
      visit root_path
      # open test link page
      click_link 'new_link_title'
      page.should have_selector("#no_comments_message")
      # add comment
      fill_in "comment_body", :with => 'this_is a new comment'
      click_button "comment_submit"
      # check that comment added
      page.should have_selector("div.comment_col")
    end

    it "should have paginator when comments count raises 5" do
      create_link(:title=>'new_link_title', :url=>'http://stackoverflow.com/questions/6085718/migrating-from-webrat-to-capybara-unsuccessfully')
      # open test link page
      click_link 'new_link_title'
      # create 6 comments
      6.times do |n|
        fill_in "comment_body", :with => "this_is a new comment N#{n+1}"
        click_button "comment_submit"
      end
      # verify pagination
      page.should have_selector("a[href*=page]")
    end
  end
end