deploy_to = "/home/ancja-urls/ancja-urls"

$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :using_rvm, true
set :rvm_ruby_string, '1.8.7@ancja-urls'        # Or whatever env you want it to run in.

require 'capistrano-deploy'
use_recipes :git, :rails, :bundle, :unicorn

server 'ancja-urls.no-ip.info', :web, :app, :db, :primary => true
set :user, 'ancja-urls'
set :deploy_to, deploy_to
set :repository, 'git@github.com:robert-hromej/olesya-urls.git'

after 'deploy:update',  'bundle:install'
#after 'deploy:restart', 'unicorn:stop'

after 'deploy:setup' do
  run "mkdir -p #{deploy_to}/pids && mkdir -p #{deploy_to}/config && mkdir -p #{deploy_to}/var"
end

namespace :unicorn do
  task :start do
    run "cd #{deploy_to} && unicorn_rails -c #{deploy_to}/config/unicorn.rb -e #{rails_env} -D"
  end

  task :stop do
    run "kill -9 `cat #{deploy_to}/pids/unicorn.pid`"
  end

  task :restart do
    run "kill -HUP `cat #{deploy_to}/pids/unicorn.pid`"
  end
end