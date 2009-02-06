# Please install Capistrano and the Engine Yard Capistrano via rubygems
# gem install capistrano --version=2.4.3
# gem install engineyard-eycap --version=0.3.7 --source=http://gems.github.com

require "eycap/recipes"

# =================================================================================================
# ENGINE YARD REQUIRED VARIABLES
# =================================================================================================
# You must always specify the application and repository for every recipe. The repository must be
# the URL of the repository you want this recipe to correspond to. The :deploy_to variable must be
# the root of the application.

set :keep_releases,       5
set :application,         "vacationstxt"
set :user,                "vacationstxt"
set :password,            "t8LzXeHr"
set :deploy_to,           "/data/#{application}"
set :monit_group,         "vacationstxt"
set :runner,              "vacationstxt"
set :repository,          "git@github.com:evizitei/vacationtxt.git"
set :scm,                 :git
set :deploy_via,          :remote_cache
set :production_database, "vacationstxt_production"
set :production_dbhost,   "mysql50-8-master"
set :dbuser,              "vacationstxt_db"
set :dbpass,              "bJtRMvr2"

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false

# =================================================================================================
# ROLES
# =================================================================================================
# You can define any number of roles, each of which contains any number of machines. Roles might
# include such things as :web, or :app, or :db, defining what the purpose of each machine is. You
# can also specify options that can be used to single out a specific subset of boxes in a
# particular role, like :primary => true.
  
task :production do
  role :web, "65.74.186.4:8096" # vacationstxt [mongrel] [mysql50-8-master]
  role :app, "65.74.186.4:8096", :mongrel => true
  role :db , "65.74.186.4:8096", :primary => true
  
  set :rails_env, "production"
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
end

# =================================================================================================
# desc "Example custom task"
# task :trialspace_custom, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
#   run <<-CMD
#     echo "This is an example"
#   CMD
# end
# 
# after "deploy:symlink_configs", "trialspace_custom"

desc "Symlink pics dir"
task :symlink_pics_dir, :roles => :app, :except => {:no_symlink => true} do
  run <<-CMD
    cd #{latest_release} &&
    ln -nfs #{shared_path}/pics #{latest_release}/public/pics
  CMD
end

after "deploy:symlink_configs", "symlink_pics_dir"
# =================================================================================================

# Do not change below unless you know what you are doing!
after "deploy", "deploy:cleanup"
after "deploy:migrations" , "deploy:cleanup"
after "deploy:update_code", "deploy:symlink_configs"

# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"

