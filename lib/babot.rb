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
      run "cd '#{root.join('bots', name)}' && git pull --rebase origin master"
      run "cd '#{root.join('bots', name)}' && bundle install"
    end

    def schedule
      Tempfile.open('schedule') do |cron|
        cron.puts(list.map { |name| instanciate(name) }.map do |bot|
          <<-eos
            every '#{bot.when}' do
              command 'cd #{root.join('bots', bot.name)} && bundle exec babot call #{bot.name}'
            end
          eos
        end)
        cron.flush
        run "whenever -w -f '#{cron.path}'"
      end
    end

    def add(name, repository)
      if repository =~ /\//
        run "ln -s '#{repository}' '#{root.join("bots", name)}'"
      else
        run "git clone '#{repository}' '#{root.join("bots", name)}'"
      end
      File.open(root.join("config", name).to_s, 'w') do |config|
        config.write({ 'consumer_key'           => "",
                       'consumer_secret'        => "",
                       'oauth_token'            => "",
                       'oauth_token_secret'     => "" }.to_yaml)
      end
    end

    def delete(name)
      run "rm -rf #{root.join('bots', name)} #{root.join('config', name)}"
    end

    def configure(name)
      run "#{ENV['EDITOR'] || 'nano'} #{root.join("config", name).to_s}"
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
      run "cd ~ && tar --exclude=.git -cf '#{Dir.pwd}/babot-#{Time.now.to_i}.tar' .babot"
    end

    def install(dump)
      run "cd ~ && rm -rf '.babot' && tar -xf '#{Dir.pwd}/#{dump}'"
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

    def run(command)
      puts command
      system command
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
