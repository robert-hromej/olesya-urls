$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.8.7@ancja-urls'        # Or whatever env you want it to run in.

require 'capistrano-deploy'
use_recipes :git, :rails, :bundle, :unicorn

server 'ancja-urls.no-ip.info', :web, :app, :db, :primary => true
set :user, 'ancja-urls'
set :deploy_to, '/home/ancja-urls/ancja-urls'
set :repository, 'git@github.com:robert-hromej/olesya-urls.git'

after 'deploy:update',  'bundle:install'
#after 'deploy:restart', 'unicorn:stop'