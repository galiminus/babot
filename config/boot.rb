require 'gaston'
require 'fileutils'
require 'git'
require 'twitter'
require 'active_support/core_ext/string/inflections'

Gaston.configure do |gaston|
  gaston.env = ENV["RACK_ENV"] || "development"
  gaston.files = Dir["./config/gaston/**/*.yml"]
end

require 'bot'
require 'bots/twitter_bot'
