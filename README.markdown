Ancja URLS
==========

Simple link aggregator. Allows add own link into global list of links. Shows links in two forms: top 20 most popular links
and top 20 most recent. Using Twitter authorization for users. Allows share links on Twitter using Twitter share button.

Public web site <http://http://ancja-urls.no-ip.info/>.

Platform
--------

Ruby 1.8.7
Rails 3.0.9
Unicorn 4.0.1
RSpec & Capybara

Setup
-----

Checkout project from Github
    cd ~
    mkdir ancjaurls
    cd ancjaurls
    git clone git://github.com/robert-hromej/olesya-urls.git

[Optional] If you are using RVM you can create gemset for project
    rvm use --create 1.8.7@ancjaurls

Install gems
    bundle install

Setup configuration
    cp config/templates/database.yml config/

Set MySQL user & password in config/database.yml

Start server
    rails s

If you want to use Unicorn server, you can use config/templates/unicorn.rb config file.

Tests
-----

To run rspec and selenium tests

    rake spec:controllers -- functional tests
    rake spec:models -- unit tests
    rake spec:requests -- integration tests
    rake spec -- all tests

Team
----

Robert Hromej <robert.hromej@gmail.com>
Fedir Kovbel <kfedia@gmail.com>
Edik Kozempel <kedgark@gmail.com>
Miroslav Nastenko <slawikdft@gmail.com>