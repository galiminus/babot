set :branch, :master
set :application, "babot.server"
set :deploy_to,   "/home/babot"
set :default_environment, { 'RAILS_ENV' => 'production' }
server "#{user}@#{application}", :app, :primary => true
