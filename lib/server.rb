require 'sinatra/base'
require 'json'

module Babot
  class Server < Sinatra::Base
    get '/bots' do
      Gaston.bots.keys.to_json
    end
  end
end
