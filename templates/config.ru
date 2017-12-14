# require 'dotenv/load' # Use this if you want plain 'rackup' over 'heroku local'
require 'facebook/messenger'
require 'sinatra'

require_relative './bot/main.rb'

map('/webhook') do
  run Facebook::Messenger::Server
end

# run regular Sinatra too
run Sinatra::Application
