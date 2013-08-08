require './config/boot'

namespace :bots do
  desc "update bots code and schedule"
  task update: [:update_code, :schedule]

  desc "update bots code"
  task :update_code do |t, args|
    Gaston.bots.map do |name, options|
      Babot::Bot.update name, options
    end
  end

  desc "update bots schedule"
  task :schedule do |t, args|
    schedule = File.open("bots/schedule.rb", "w")
    Gaston.bots.map do |name, options|
      bot = Babot::Bot.instanciate name, options
      schedule.puts <<-eos
      every '#{bot.when}' do
        rake 'bots:call[#{name}]'
      end
      eos
    end
    schedule.close
  end

  desc "call the bot"
  task :call, :name do |t, args|
    options = Gaston.bots[args[:name]]
    Twitter.configure do |config|
      config.consumer_key = options.consumer_key
      config.consumer_secret = options.consumer_secret
      config.oauth_token = options.oauth_token
      config.oauth_token_secret = options.oauth_token_secret
    end
    Babot::Bot.instanciate(args[:name], options).call.tap do |tweet|
      Twitter.update tweet
    end
  end
end
