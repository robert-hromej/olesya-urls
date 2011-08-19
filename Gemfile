source 'http://rubygems.org'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
gem 'rails', '3.0.9'

gem 'jquery-rails'
gem 'coffee-script'
gem 'yui-compressor', :require => 'yui/compressor'
gem 'sass'
gem 'json' # sprocket dependency for Ruby 1.8 only
gem 'sprockets', :git => 'git://github.com/sstephenson/sprockets.git'
gem 'win32-open3' # for windows platform

#gem "rack", "1.2.3"
#gem 'rake', '0.8.7'

gem 'mysql'
#gem 'mysql2', '0.2.11'

gem 'oauth'
gem 'twitter'

# Use unicorn as the web server
#gem 'kgio'#, '2.2.0'
gem 'unicorn' #, '3.4.0'

gem "will_paginate", "~> 3.0.pre2"

group :development, :test do
#  gem 'win32-process' # for windows platform
  gem "rspec"
  gem "rspec-rails", "~> 2.4"
  gem 'factory_girl_rails', '1.0'
  gem 'capybara'
  gem "redgreen" # for ruby187
  #gem 'mynyml-redgreen' # for ruby192
  gem 'spork', '0.9.0.rc5'
  gem 'database_cleaner'
  #gem "selenium-webdriver", "0.2.2" # for Chrome WebDrive
  gem 'capistrano-deploy', '~> 0.1.1', :require => nil
end

