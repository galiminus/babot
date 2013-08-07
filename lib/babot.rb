require 'sidekiq'
require 'twitter'
require 'gaston'
require 'git'
require 'fileutils'
require 'bundler'
require 'active_support'

Gaston.configure do |gaston|
  gaston.env = ENV["RACK_ENV"] || "development"
  gaston.files = Dir["./config/gaston/**/*.yml"]
end

require 'bot'
require 'bots/twitter_bot'

bots = Babot::Bot.run_all

bots.each do |bot|
  puts "#{bot.name}: #{bot.when}"
end
