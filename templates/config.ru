# require 'dotenv/load' # Use this if you want plain 'rackup' over 'heroku local'
require 'sinatra'
require 'facebook/messenger'
require 'rubotnik/autoloader'

map('/webhook') do
  run Facebook::Messenger::Server
end

# run regular sinatra too
run Sinatra::Application
