#!/bin/bash

curl -L https://get.rvm.io | bash -s stable

source ~/.rvm/scripts/rvm
rvm install 1.9.3
rvm use 1.9.3 --default
rvm rubygems current
gem install rails --no-rdoc --no-ri

cd /vagrant
bundle install
rake db:setup
