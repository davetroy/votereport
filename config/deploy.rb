# Use Git for deployment - git-specific options
default_run_options[:pty] = true
set :scm, "git"
set :repository,  "git@github.com:davetroy/votereport.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1

set :application, "votereport"
set :keep_releases, 3

role :app, "votereport.us"
role :daemons, "votereport.us"
#role :voip, "voip.votereport.us"
role :db, "votereport.us", :primary=>true

set :use_sudo, false
set :user, application
set :deploy_to, "/home/#{application}"

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :daemons do
  desc "Start Daemons"
  task :start, :roles => :daemons do
    run "#{deploy_to}/current/script/daemons start"
  end

  desc "Stop Daemons"
  task :stop, :roles => :daemons do
    run "#{deploy_to}/current/script/daemons stop"
		run "sleep 5 && killall -9 ruby"
  end
end

desc "Link in the production database.yml" 
task :after_update_code do
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml" 
end
