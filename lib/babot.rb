require 'fileutils'
require 'git'
require 'twitter'
require 'pathname'
require 'yaml'
require 'tempfile'
require 'whenever'
require 'active_support/core_ext/string/inflections'
require 'bundler/cli'

class Babot

  class << self

    def update(name)
      git = Git.open(root.join("bots", name), :log => Logger.new(STDOUT))
      git.fetch "origin"
      git.merge "origin", "master"
      system "cd #{root.join('bots', name)} && bundle install"
    end

    def schedule
      cron = File.open root.join("schedule.rb"), "w"
      list.map { |name| instanciate(name) }.each do |bot|
        cron.puts <<-eos
            every '#{bot.when}' do
              command 'cd #{root.join('bots', bot.name)} && bundle exec babot call #{bot.name}'
            end
          eos
      end
      cron.close

      Whenever::CommandLine.execute(file: cron.path, write: true)
    end

    def add(name, repository)
      if repository =~ /\//
        FileUtils.ln_s repository, root.join("bots", name)
      else
        Git.clone repository, root.join("bots", name)
      end
      File.open(root.join("config", name).to_s, 'w') do |config|
        config.write({ 'consumer_key'           => "",
                       'consumer_secret'        => "",
                       'oauth_token'            => "",
                       'oauth_token_secret'     => "" }.to_yaml)
      end
    end

    def delete(name)
      FileUtils.rm_rf root.join("bots", name)
      FileUtils.rm_f root.join("config", name)
    end

    def configure(name)
      system "#{ENV['EDITOR'] || 'nano'} #{root.join("config", name).to_s}"
    end

    def call(name)
      Twitter.update dry(name)
    end

    def list
      Dir.entries(root.join "bots").reject { |name| name =~ /^\./ }
    end

    def dry(name)
      instanciate(name).call
    end

    def dump
      
    end

    def install
      
    end

    def instanciate(name)
      require Babot.root.join("bots", name, 'lib', name)

      options = YAML.load_file(root.join("config", name))
      Babot::const_get(name.camelize).new(name, options)
    rescue StandardError, ScriptError => error
      puts error, error.backtrace
    end

    def root
      Pathname.new(ENV["HOME"]).join ".babot"
    end
  end

  attr_accessor :name

  def initialize(name, options)
    @name = name

    Twitter.configure do |config|
      config.consumer_key = options['consumer_key']
      config.consumer_secret = options['consumer_secret']
      config.oauth_token = options['oauth_token']
      config.oauth_token_secret = options['oauth_token_secret']
    end
  end
end
