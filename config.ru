# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require "babot"
require "server"

run Babot::Server
