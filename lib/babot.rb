require 'twitter'

class Babot
  def Babot.run!
    new.call
  end

  def twitter
    return @twitter if @twitter

    options = YAML::load_file "config/credentials.yml"

    @twitter = Twitter::REST::Client.new do |config|
      config.consumer_key = options['consumer_key']
      config.consumer_secret = options['consumer_secret']
      config.oauth_token = options['oauth_token']
      config.oauth_token_secret = options['oauth_token_secret']
    end
  end
end
