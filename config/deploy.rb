require "bundler/capistrano"
require 'capistrano/ext/multistage'

set :application, "cultivate-london"
set :scm, :git
set :repository,  "git://github.com/alnorth29/cultivate-london.git"

set :user, "alasdair"
set :use_sudo, false

set :stages, ["staging", "production"]
set :default_stage, "staging"
