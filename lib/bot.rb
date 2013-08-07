module Babot
  class Bot
    attr_accessor :name, :repository

    def Bot.run_all
      Gaston.bots.map do |name, options|
        run name, options
      end.compact
    end

    def Bot.run(name, options)
      unless File.exists? root(name)
        clone name, options[:repository]
      end

      require "./#{Babot::Bot.path(name)}"

      Babot::const_get(name.camelize).new(name, options).tap do |bot|
        bot.pull!
      end
    rescue StandardError, ScriptError => error
      puts error, error.backtrace
    end

    def Bot.clone(name, repository)
      Git.clone repository, Pathname.new("lib").join("bots", name)
    end

    def Bot.root(name)
      Pathname.new("lib").join "bots", name
    end

    def Bot.path(name)
      Bot.root(name).join "lib", name
    end

    def initialize(name, options)
      @name = name
    end

    def pull!
      git.pull
    end

    protected
    def root
      Bot.root name
    end

    def path
      Bot.path name
    end

    def git
      @git ||= Git.open(root)
    end
  end
end
