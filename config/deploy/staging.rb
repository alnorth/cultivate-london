server "hezekiah.alnorth.com", :app, :web, :db, :primary => true

set :deploy_to, "/var/www/cultivatelondon.alnorth.com"
set :current_path, File.join(deploy_to, current_dir)

set :unicorn_env, "staging"
after 'deploy:restart', 'unicorn:reload'
