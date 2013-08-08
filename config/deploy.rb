set :application, "babot"
set :user, "babot"
set :appname, user

require "rvm/capistrano"

set :rvm_ruby_string, "2.0.0"

require "capistrano/af83"

set :repository,  "git@github.com:phorque/babot.git"
set :scm, :git

after 'deploy:update_code' do
  run "cd #{current_path} && bundle exec rake bots:update"
end
