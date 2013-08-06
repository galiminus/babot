require 'sidekiq'
require 'twitter'
require 'gaston'
require 'git'
require 'fileutils'
require 'bundler'

Gaston.configure do |gaston|
  gaston.env = ENV["RACK_ENV"] || "development"
  gaston.files = Dir["./config/gaston/**/*.yml"]
end

require 'bot'

Gaston.bots.each do |name, options|
  puts "Checkout: #{name}"
  Babot::Bot.new(name, options).pull!
end
