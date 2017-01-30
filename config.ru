require './app'
require_relative 'bot'

# run both Sinatra and facebook-messenger on /webhook
map("/webhook") do
  run Sinatra::Application
  run Facebook::Messenger::Server
end

# run regular sinatra for other paths
run Sinatra::Application
