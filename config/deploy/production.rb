set :branch, :production
set :application, "server.domain"
set :deploy_to,   "/home/babot"
set :default_environment, { 'RAILS_ENV' => 'production' }
server "#{user}@#{application}", :app, :primary => true
