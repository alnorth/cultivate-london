require "bundler/capistrano"

# Needs to be set before unicorn require - https://github.com/sosedoff/capistrano-unicorn/issues/39
set :application, "cultivate-london"
set :scm, :git
set :repository,  "git://github.com/alnorth29/cultivate-london.git"
server "hezekiah.alnorth.com", :app, :web, :db, :primary => true

set :user, "alasdair"
set :use_sudo, false

set :ruby_env, "production"
set(:unicorn_env) { ruby_env }
set(:app_env) { ruby_env }
set :deploy_to, "/var/www/cultivatelondon.alnorth.com"
set(:current_path) { File.join(deploy_to, current_dir) }

require 'capistrano-unicorn'

after 'deploy:restart', 'unicorn:reload'

namespace :deploy do
  desc 'Load DB schema - CAUTION: rewrites database!'
  task :load_schema, :roles => :app do
    raise RuntimeError.new('load_schema aborted!') unless Capistrano::CLI.ui.ask("Are you sure to wipe the entire database (anything other than 'yes' aborts):") == 'yes'
    run "cd #{current_path}; bundle exec rake db:schema:load RAILS_ENV=#{rails_env}"
  end
end
