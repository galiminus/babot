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
        rake 'bots:update'
      end
      eos
    end
    schedule.close
  end
end
