# config valid for current version and patch releases of Capistrano
lock "~> 3.15.0"

set :application, "checkjjaek3"
set :repo_url, "git@github.com:ShinJaehun/checkjjaek3.git"
set :branch, :master
set :use_sudo, false
set :deploy_via, :remote_cache

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/home/ubuntu/#{fetch :application}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"
set :linked_files, %w{config/application.yml config/database.yml config/master.key}

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads public/img}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
namespace :deploy do
  namespace :check do
    before :linked_files, :set_master_key do
      on roles(:app), in: :sequence, wait: 10 do
        unless test("[ -f #{shared_path}/config/application.yml ]")
          upload! 'config/application.yml', "#{shared_path}/config/application.yml"
        end
        unless test("[ -f #{shared_path}/config/master.key ]")
          upload! 'config/master.key', "#{shared_path}/config/master.key"
        end
        unless test("[ -f #{shared_path}/config/database.yml ]")
          upload! 'config/database.yml', "#{shared_path}/config/database.yml"
        end
      end
    end
  end
end

#before "deploy:assets:precompile", "deploy:yarn_install"
#namespace :deploy do
#  desc "Run rake yarn install"
#  task :yarn_install do
#    on roles(:web) do
#      within release_path do
#        execute("cd #{release_path} && yarn install --silent --no-progress --no-audit --no-optional")
#      end
#    end
#  end
#end
#
#after 'deploy:updated', 'assets:precompile'
