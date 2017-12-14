require 'rubotnik'

# Subscribe your bot to a Facebook Page (put access token and verify token in .env)

Rubotnik.subscribe(ENV['ACCESS_TOKEN'])

################# PROFILE ##################

# Configure profile for your bot (Start Button, Greeting, Menu)
START_BUTTON = {
  get_started: {
    payload: 'START'
  }
}

START_GREETING = {
  greeting: [
    {
      locale: 'default',
      text: "Hello and welcome, {{user_first_name}}! Say 'hi!'"
    },
    {
      locale: 'fr_FR',
      text: 'Bienvenue, {{user_first_name}}!'
    }
  ]
}

Rubotnik.set_profile(START_BUTTON, START_GREETING)

################ ROUTING ###################

# Route your messages
Rubotnik.route :message do
  # Trigger with "hello" or "HELLOOOO!"
  bind 'hi', 'hello', 'bonjour' do
    say 'Hello from your new bot!'
  end

  # TODO: open_thread_with instead of reply_with?
  # Start a thread (you have to provide an opening message, optionally quick replies)
  bind 'ask', to: :gauge_affection, reply_with: {
     text: "Do you like me?",
     quick_replies: ['Yes', 'No'] # payloads "YES" and "NO" are inferred
   }

   # Use 'all' flag if you want to trigger a command only if all patterns
   # are present in a message (will trigger with each of them by default)
   bind 'what', 'my', 'name', all: true do
     info = get_user_info(:first_name) # helper to get fields from Graph API
     say info[:first_name]
   end

   # Invoked if none of the commands recognized. Has to come last, after all binds
   default do
     say "Sorry I did not get it"
   end
end

# Route your postbacks
Rubotnik.route :postback do
  bind 'START' do
    say "Welcome!"
  end
end

# Use Sinatra here if need to
# TODO: Make sure we can implement 'say' in webhooks for incoming POSTs
get '/' do
  'I can have a landing page too!'
end

# TEST WITH LOCALHOST
# 1. Have both Heroku CLI and ngrok
# 2. Run 'heroku local' from console and enjoy, it will start Puma on port 5000
# 3. Expose port 5000 to the Internet with 'ngrok http 5000'
# 4. Provide your ngrok http_s_(!) address in Facebook Developer Dashboard
#    for webhook validation.
# 5. Go talk to your bot!
