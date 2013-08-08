Babot helps you manage your Twitter bots.

The file `config/gaston/bots.yml` contains, for each bot, the git
    repository and the API keys.

A bot is a git repository containing :

- a Gemfile
- a lib directory with a [name_of_the_bot].rb file

Look at https://github.com/phorque/twitter-test-bot for a simple bot
    example.

A bot inherit from the Babot::Bot class and must implement a `when`
    method returning a 'cron-style' time. When the time is reached the
    `call` method will be called and its result will be posted to
    Twitter.