require 'spork'
require "have_htm_tag_helper"

Spork.prefork do

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  require 'capybara/rspec'
  require 'capybara/rails'

  RSpec.configure do |config|
    config.mock_with :rspec
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
  end
end

Spork.each_run do
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
end
