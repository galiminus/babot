set :application, "babot"
set :user, "babot"
set :appname, user

require "capistrano/af83"

set :repository,  "git@github.com:phorque/babot.git"
set :scm, :git
