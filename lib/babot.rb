require 'fileutils'
require 'git'
require 'twitter'
require 'pathname'
require 'yaml'
require 'tempfile'
require 'active_support/core_ext/string/inflections'

class Babot

  class << self

    def update
      Dir["#{bots_root}/*"].each do |repository|
        Git.open(repository).pull
      end
    end

    def schedule
      File.open(root.join("schedule.rb"), "w") do |schedule|
        @@config['bots'].map do |name, options|
          bot = instanciate name, options
          schedule.puts <<-eos
            every '#{bot.when}' do
              rake 'bots:call[#{name}]'
            end
          eos
        end
        Whenever::CommandLine.execute(file: schedule.path, write: true)
      end
    end

    def add(name, repository)
      Git.clone repository, bot_root(name)
      File.open(root.join("config", name).to_s, 'w') do |config|
        config.write({ 'consumer_key'           => "",
                       'consumer_secret'        => "",
                       'oauth_token'            => "",
                       'oauth_token_secret'     => "" }.to_yaml)
      end
    end

    def delete(name)
      FileUtils.rm_rf bot_root(name)
      FileUtils.rm_f config_root.join(name)
    end

    def configure(name)
      system "#{ENV['EDITOR'] || 'nano'} #{root.join("config", name).to_s}"
    end

    def call(name)
      Twitter.update dry(name)
    end

    def dry(name)
      instanciate(name, YAML.load_file(config_root.join name)).call
    end

    def instanciate(name, config)
      require Babot.bot_root(name).join('lib', name)

      Babot::const_get(name.camelize).new(name)
    rescue StandardError, ScriptError => error
      puts error, error.backtrace
    end

    def root
      Pathname.new(ENV["HOME"]).join ".babot"
    end

    def bots_root
      root.join("bots")
    end

    def config_root
      root.join("config")
    end

    def bot_root(name)
      bots_root.join name
    end
  end

  def initialize(options)
    Twitter.configure do |config|
      config.consumer_key = options['consumer_key']
      config.consumer_secret = options['consumer_secret']
      config.oauth_token = options['oauth_token']
      config.oauth_token_secret = options['oauth_token_secret']
    end
  end
end
