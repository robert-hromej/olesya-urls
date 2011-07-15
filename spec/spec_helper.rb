require 'rubygems'
#require 'capybara/rspec'
#require 'capybara/rails'
require 'spork'

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
    #    config.include(Capybara, :type => :integration)
  end
  DEFAULT_HOST = 'http://localhost:3000/'
  TWITTER_CREDENTIALS = {:login => "testing_sw", :pass => 'qwerty123'}

  def login(user)
    session[:current_user_id] = user.nil? ? Factory(:user, :screen_name => Factory.next(:screen_name)) : user
  end

  def integration_login(options=nil)
    Capybara.current_driver = :selenium
      #Capybara.register_driver :selenium do |app|
      #  Capybara::Driver::Selenium.new(app,
      #                                 :browser => :chrome
      #                                 :desired_capabilities => :chrome)
      #end
      #Capybara.current_driver.for :firefox, :profile => Profile.new
    visit root_path
    click_link 'twitter_login_but'
    fill_in :username_or_email, :with => options.nil? ? TWITTER_CREDENTIALS[:login] : options[:login]
    fill_in "password", :with => options.nil? ? TWITTER_CREDENTIALS[:pass] : options[:pass]
    click_button 'allow'
    visit root_path
    click_link 'LOGOUT'
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





