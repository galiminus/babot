module Babot
  class Bot
    attr_accessor :name, :repository

    def Bot.instanciate(name, options)
      require "./#{Babot::Bot.path(name)}"

      Babot::const_get(name.camelize).new(name, options)
    rescue StandardError, ScriptError => error
      puts error, error.backtrace
    end

    def Bot.update(name, options)
      unless File.exists? root(name)
        clone name, options[:repository]
      end
      Bot.instanciate(name, options).pull!
    end

    def Bot.clone(name, repository)
      Git.clone repository, Pathname.new("bots").join(name)
    end

    def Bot.root(name)
      Pathname.new("bots").join name
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
