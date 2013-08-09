require 'gaston'
require 'fileutils'
require 'git'
require 'twitter'
require 'pathname'
require 'yaml'
require 'active_support/core_ext/string/inflections'

class Babot
  attr_accessor :name, :options

  def Babot.configure!
    @@config = YAML::load(File.open Pathname.new(ENV["HOME"]).join(".babot"))
  end

  def Babot.update
    @@config['bots'].map do |name, options|
      unless File.exists? root(name)
        clone name, options[:repository]
      end
      Babot.instanciate(name, options).pull!
    end
  end

  def Babot.schedule
    schedule = File.open("bots/schedule.rb", "w")
    @@config['bots'].map do |name, options|
      bot = Babot.instanciate name, options
      schedule.puts <<-eos
      every '#{bot.when}' do
        rake 'bots:call[#{name}]'
      end
      eos
    end
    schedule.close
  end

  def Babot.call(name)
    bot = Babot.instanciate(name, @@config['bots'][name])
    bot.configure
    Twitter.update bot.call
  end

  def Babot.instanciate(name, options)
    require "./#{Babot.path(name)}"

    Babot::const_get(name.camelize).new(name, options)
  rescue StandardError, ScriptError => error
    puts error, error.backtrace
  end

  def Babot.clone(name, repository)
    Git.clone repository, Pathname.new("bots").join(name)
  end

  def Babot.root(name)
    Pathname.new("bots").join name
  end

  def Babot.path(name)
    Babot.root(name).join "lib", name
  end

  def initialize(name, options)
    @name = name
    @options = options
  end

  def pull!
    git.pull
  end

  def configure
    Twitter.configure do |config|
      config.consumer_key = options[:consumer_key]
      config.consumer_secret = options[:consumer_secret]
      config.oauth_token = options[:oauth_token]
      config.oauth_token_secret = options[:oauth_token_secret]
    end
  end

  protected
  def root
    Babot.root name
  end

  def path
    Babot.path name
  end

  def git
    @git ||= Git.open(root)
  end
end
