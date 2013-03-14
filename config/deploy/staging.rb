server "hezekiah.alnorth.com", :app, :web, :db, :primary => true
set :deploy_to, "/var/www/cultivatelondon.alnorth.com"
set :unicorn_env, "staging"
after 'deploy:restart', 'unicorn:reload'
