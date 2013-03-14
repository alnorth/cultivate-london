require "bundler/capistrano"
require 'capistrano/ext/multistage'

# Needs to be set before unicorn require - https://github.com/sosedoff/capistrano-unicorn/issues/39
set :application, "cultivatelondon"

require 'capistrano-unicorn'

set :application, "cultivate-london"
set :scm, :git
set :repository,  "git://github.com/alnorth29/cultivate-london.git"

set :user, "alasdair"
set :use_sudo, false

set :stages, ["staging", "production"]
set :default_stage, "staging"
set :current_path, ""
