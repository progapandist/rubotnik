require_relative 'bot'

# run both Sinatra and facebook-messenger on /webhook
map('/webhook') do
  # run Sinatra::Application # APPARENTLY WE DON'T NEED THIS LINE
  run Facebook::Messenger::Server
end

# run regular sinatra for other paths
run Sinatra::Application
