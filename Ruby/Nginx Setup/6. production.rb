# capistrano production config
#
# config/deploy/production.rb


server "8.8.8.8",                :app, :web, :db, :primary => true
set :branch,                     "production"
set :deploy_to,                  "/home/app/public_html/app_production"
set :rails_env,                  "production"
