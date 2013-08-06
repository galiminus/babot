module Babot
  class Bot
    attr_accessor :name, :repository

    def initialize(name, options)
      @name = name
      @repository = options.delete(:repository)

      unless File.exists? checkout_path
        @git = Git.clone repository, checkout_path
      end
    end

    def pull!
      git.pull
    end

    protected
    def checkout_path
      Pathname.new("lib").join("bots").join(name)
    end

    def git
      @git ||= Git.open(checkout_path)
    end
  end
end
