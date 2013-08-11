require 'fileutils'
require 'twitter'
require 'pathname'
require 'yaml'

class Babot

  class << self

    def update(name)
      cmd "cd '#{root.join(name)}' && git pull --rebase origin master && bundle install"
    end

    def schedule
      list.each do |name|
        cmd "whenever -i #{name} -f #{root.join(name, 'config', 'schedule.rb')}"
      end
    end

    def add(name, repository)
      if repository =~ /^\//
        cmd "ln -s '#{repository}' '#{root.join(name)}'"
      else
        cmd "git clone '#{repository}' '#{root.join(name)}'"
      end
      File.open(root.join(name, "config", "credentials.yml").to_s, 'w') do |config|
        config.write({ 'consumer_key'           => "",
                       'consumer_secret'        => "",
                       'oauth_token'            => "",
                       'oauth_token_secret'     => "" }.to_yaml)
      end
    end

    def delete(name)
      cmd "rm -rf '#{root.join(name)}' '#{root.join(name, 'config', 'credentials.yml')}'"
    end

    def configure(name)
      cmd "#{ENV['EDITOR'] || 'nano'} '#{root.join(name, "config", 'credentials.yml')}'"
    end

    def run(name)
      options = YAML::load_file root.join(name, "config", 'credentials.yml')

      Twitter.configure do |config|
        config.consumer_key = options['consumer_key']
        config.consumer_secret = options['consumer_secret']
        config.oauth_token = options['oauth_token']
        config.oauth_token_secret = options['oauth_token_secret']
      end
      load Babot.root.join(name, 'babot.run').to_s
    end

    def list
      Dir.entries(root).reject { |name| name =~ /^\./ }
    end

    def dump
      cmd "cd ~ && tar --exclude=.git -cf '#{Dir.pwd}/babot-#{Time.now.to_i}.tar' .babot"
    end

    def install(dump)
      cmd "cd ~ && rm -rf '.babot' && tar -xf '#{Dir.pwd}/#{dump}'"
    end

    def push(remote)
      cmd "scp -qr '#{root}' '#{remote}:~/.' && ssh '#{remote}' 'babot schedule'"
    end

    def root
      Pathname.new(ENV["HOME"]).join ".babot"
    end

    def cmd(command)
      puts command
      system command
    end

    def run!
      Twitter.update new.call
    end
  end
end
