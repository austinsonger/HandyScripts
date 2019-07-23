# Capistrano configuration. Now with TRUE zero-downtime unless DB migration.
# 
# require 'new_relic/recipes'         - Newrelic notification about deployment
# require 'capistrano/ext/multistage' - We use 2 deployment environment: staging and production.
# set :deploy_via, :remote_cache      - fetch only latest changes during deployment
# set :normalize_asset_timestamps     - no need to touch (date modification) every assets
# "deploy:web:disable"                - traditional maintenance page (during DB migrations deployment)
# task :restart                       - Unicorn with preload_app should be reloaded by USR2+QUIT signals, not HUP
#
# http://unicorn.bogomips.org/SIGNALS.html
# "If “preload_app” is true, then application code changes will have no effect; 
# USR2 + QUIT (see below) must be used to load newer code in this case"
# 
# config/deploy.rb


require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'new_relic/recipes'

set :stages,                     %w(staging production)
set :default_stage,              "staging"

set :scm,                        :git
set :repository,                 "..."
set :deploy_via,                 :remote_cache
default_run_options[:pty]        = true

set :application,                "app"
set :use_sudo,                   false
set :user,                       "app"
set :normalize_asset_timestamps, false


before "deploy",                 "deploy:delayed_job:stop"
before "deploy:migrations",      "deploy:delayed_job:stop"

after  "deploy:update_code",     "deploy:symlink_shared"
before "deploy:migrate",         "deploy:web:disable", "deploy:db:backup"

after  "deploy",                                      "newrelic:notice_deployment", "deploy:cleanup", "deploy:delayed_job:restart"
after  "deploy:migrations",      "deploy:web:enable", "newrelic:notice_deployment", "deploy:cleanup", "deploy:delayed_job:restart"


namespace :deploy do

  %w[start stop].each do |command|
    desc "#{command} unicorn server"
    task command, :roles => :app, :except => { :no_release => true } do
      run "#{current_path}/config/server/#{rails_env}/unicorn_init.sh #{command}"
    end
  end

  desc "restart unicorn server"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{current_path}/config/server/#{rails_env}/unicorn_init.sh upgrade"
  end


  desc "Link in the production database.yml and assets"
  task :symlink_shared do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  namespace :delayed_job do 
    desc "Restart the delayed_job process"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec script/delayed_job restart" rescue nil
    end
    desc "Stop the delayed_job process"
    task :stop, :roles => :app, :except => { :no_release => true } do
      run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec script/delayed_job stop" rescue nil
    end
  end


  namespace :db do
    desc "backup of database before migrations are invoked"
    task :backup, :roles => :db, :only => { :primary => true } do
      filename = "#{deploy_to}/shared/db_backup/#{stage}_db.#{Time.now.utc.strftime("%Y-%m-%d_%I:%M")}_before_deploy.gz"
      text = capture "cat #{deploy_to}/current/config/database.yml"
      yaml = YAML::load(text)["#{stage}"]
    
      on_rollback { run "rm #{filename}" }
      run "mysqldump --single-transaction --quick -u#{yaml['username']} -h#{yaml['host']} -p#{yaml['password']} #{yaml['database']} | gzip -c > #{filename}"
    end
  end


  namespace :web do
    desc "Maintenance start"
    task :disable, :roles => :web do
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }
      page = File.read("public/503.html")
      put page, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
    
    desc "Maintenance stop"
    task :enable, :roles => :web do
      run "rm #{shared_path}/system/maintenance.html"
    end
  end

end


namespace :log do
  desc "A pinch of tail"
  task :tailf, :roles => :app do
    run "tail -n 10000 -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
      puts "#{data}"
      break if stream == :err
    end
  end
end