require 'dotenv/load' # comment this line out before pushing to Heroku! 
require 'sinatra'

# NOTE: ENV variables should be set directly in terminal for testing on localhost

# Talk to Facebook
get '/webhook' do
  params['hub.challenge'] if ENV["VERIFY_TOKEN"] == params['hub.verify_token']
end

get "/" do
  "Nothing to see here"
end
