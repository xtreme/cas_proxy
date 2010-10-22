require "bundler/capistrano"

#############################################################
#	Application
#############################################################

set :user, "rails"
set :application, "cas_proxy"
set :deploy_to, "/srv/rails/#{application}/production"


#############################################################
#	Git
#############################################################

set :scm, :git
set :scm_verbose, true
set :repository,  "git@github.com:xtreme/cas_proxy.git"
set :git_enable_submodules, true

#############################################################
#	Settings
#############################################################

set :use_sudo, false
set :branch, "master"
set :rails_env, "production"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
default_environment["PATH"] = "/var/lib/gems/1.8/bin/:$PATH"

set :domain, "46.51.181.54"
role :app, domain, :primary => true
server domain, :web

set :application_server, :passenger

#############################################################
#	Tasks
#############################################################

namespace :deploy do
  task :stop, :roles => :app do
    run "touch #{File.join(current_path,'tmp','stop.txt')}"
  end
  task :start, :roles => :app do
    run "rm -f #{current_path}/tmp/stop.txt"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end  

  desc <<-DESC
    Run the migrate rake task. By default, it runs this in most recently \
    deployed version of the app. However, you can specify a different release \
    via the migrate_target variable, which must be one of :latest (for the \
    default behavior), or :current (for the release indicated by the \
    `current' symlink). Strings will work for those values instead of symbols, \
    too. You can also specify additional environment variables to pass to rake \
    via the migrate_env variable. Finally, you can specify the full path to the \
    rake executable by setting the rake variable. The defaults are:
  
      set :rake,           "rake"
      set :rails_env,      "production"
      set :migrate_env,    ""
      set :migrate_target, :latest
  DESC
  task :migrate, :roles => :app, :only => { :primary => true } do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    migrate_env = fetch(:migrate_env, "")
    migrate_target = fetch(:migrate_target, :latest)
  
    directory = case migrate_target.to_sym
      when :current then current_path
      when :latest  then current_release
      else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
      end
  
    run "cd #{directory}; #{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:migrate"
  end
end

desc "Watch multiple log files at the same time"
task :tail_log, :roles => :app do
  stream "tail -f #{release_path}/log/production.log"
end

desc "Echo the remote server PATH"
task :path, :roles => :app do
  run "echo $PATH"
  run "which ruby"
end

desc "Open script/console on the remote machine"
task :console, :roles => :app do
  input = ''
  cmd = "cd #{current_path} && bundle exec rails c #{rails_env}"
  run cmd, :once => true do |channel, stream, data|
    next if data.chomp == input.chomp || data.chomp == ''
    print data
    channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
  end
end

