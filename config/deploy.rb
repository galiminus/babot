set :application, "babot"
set :user, "babot"
set :appname, user

require "rvm/capistrano"

set :rvm_ruby_string, "2.0.0"

require "capistrano/af83"

set :repository,  "git@github.com:phorque/babot.git"
set :scm, :git

after 'deploy:restart' do
  config ||= "config/gaston/bots.yml"
  upload config, "#{current_path}/config/gaston/bots.yml"

  run "cd #{current_path} && bundle exec rake bots:update && bundle exec whenever -f bots/schedule.rb -w"
end
