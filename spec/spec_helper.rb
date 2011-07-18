require 'rubygems'
#require 'capybara/rails'
require 'spork'
#require 'redgreen' # for ruby19

# todo COMMENTS!
Spork.prefork do

  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Add this to load Capybara integration:
  require 'capybara/rspec'
  require 'capybara/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true
    #config.include(Capybara, :type => :integration)
  end
  DEFAULT_HOST = 'http://localhost:3000/'
  TWITTER_CREDENTIALS = {:login => "testing_sw", :pass => 'qwerty123'}

  def login(user)
    session[:current_user_id] = user.nil? ? Factory(:user, :screen_name => Factory.next(:screen_name)) : user
  end
  #  <b>==DOCUMENTATION==</b>
  #  <b>logs in with twitter to create session</b>
  #
  #  <b>Usage</b>
  #    integration_login
  #
  #    note you can add parameters when using this function to login by other user
  def integration_login(options=nil)
    #require 'selenium/webdriver'
    #driver = Selenium::WebDriver.for :chrome
    #Capybara.current_driver = driver
    Capybara.current_driver = :selenium
    visit root_path
    click_link LOGIN_BUTTON
    fill_in TWITTER_LOGIN_FIELD, :with => options.nil? ? TWITTER_CREDENTIALS[:login] : options[:login]
    fill_in TWITTER_PASSWORD_FIELD, :with => options.nil? ? TWITTER_CREDENTIALS[:pass] : options[:pass]
    click_button ALLOW_BUTTON
    visit root_path
    click_link LOGOUT_BUTTON
  end

  #  <b>==DOCUMENTATION==</b>
  #  <b>creates new link</b>
  #
  #  <b>Usage</b>
  #    create_link(:title=>'new_link_title', :url=>'http://valid_url')
  #    create_link(:test=>false, :title=>'new_link_title', :url=>'http://valid_url')
  #
  #    parameter [test] must be false to add new link if it already exists
  def create_link(options={})
    test = !(options[:test].nil? ? true : options[:test])
    visit root_path
    if ((!page.html.has_html_tag?(:a, :class=>'title_link', :content=>options[:title], :print=>false)) || test)
      page.should have_selector('a#add_link')
      click_link ADD_LINK_BUTTON
      fill_in NEW_LINK_TITLE_FIELD, :with=>options[:title]
      fill_in NEW_LINK_URL_FIELD, :with=>options[:url]
      click_button CREATE_LINK_BUTTON
    end
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  require "have_htm_tag_helper"
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#

LOGIN_BUTTON = 'twitter_login_but'
TWITTER_LOGIN_FIELD = "username_or_email"
TWITTER_PASSWORD_FIELD = "password"
ALLOW_BUTTON = 'allow'
LOGOUT_BUTTON = 'LOGOUT'
ADD_LINK_BUTTON = 'add_link'
NEW_LINK_TITLE_FIELD = 'new_link_title'
NEW_LINK_URL_FIELD = 'new_link_url'
CREATE_LINK_BUTTON = 'Create'