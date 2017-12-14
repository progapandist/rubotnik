require 'rubotnik'
# require_relative all files in "bot" folder or do it by hand
Rubotnik::Autoloader.load('bot')

# Subscribe your bot to a Facebook Page
# (put access token and verify token in .env)
Rubotnik.subscribe(ENV['ACCESS_TOKEN'])

# Set welcome screen, "get started" button and a menu (all optional)
# Edit profile.rb before uncommenting next line
# Rubotnik.set_profile(Profile::START_BUTTON, Profile::START_GREETING, Profile::SIMPLE_MENU)

# Read the doc to find out more about built-in UI classes
LOCATION_PROMPT = UI::QuickReplies.location

####################### HANDLE INCOMING MESSAGES ##############################

Rubotnik.route :message do
  # Will work for all variations of these three greetings
  bind 'hi', 'hello', 'bonjour' do
    say 'Hello from your new bot!'
  end

  # Start a thread (and provide an opening message with optional quick replies).
  # You have to define start_conversation methods inside Command module
  # and treat user's response to your "reply_with" message there.
  bind 'how', 'do', 'you', all: true, to: :start_conversation, reply_with: {
     text: "I'm doing fine! You?",
     quick_replies: [['Good!', 'OK'], ['Not so well', 'NOT_OK']]
     # second item in nested array will be the contents of message.quick_reply,
     # once the user makes a selection. It will be quick reply text in ALL CAPS
     # if you pass strings instead of arrays
     # (e.g. quick_replies: ['Yes', 'No'] - payloads "YES" and "NO" are inferred)
   }

   # Use 'all' flag if you want to trigger a command only if all patterns
   # are present in a message (will trigger with each of them by default)
   bind 'what', 'my', 'name', all: true do
     info = get_user_info(:first_name) # helper to get fields from Graph API
     say info[:first_name]
   end

   # look for example of an API call with HTTParty in commands/location.rb
   bind 'where', 'am', 'I', all: true, to: :lookup_location, reply_with: {
      text: 'Let me know your location',
      quick_replies: LOCATION_PROMPT
    }

    # look for more UI examples in commands/ui_examples.rb
    bind 'image', to: :show_image

   # Invoked if none of the commands recognized. Has to come last, after all binds
   default do
     say "Sorry I did not get it"
   end
end

####################### HANDLE INCOMING POSTBACKS ##############################

Rubotnik.route :postback do
  # postback from "Get Started" button
  bind 'START' do
    say "Welcome!"
  end
end

####################### HANDLE OTHER REQUESTS (NON-FB) #########################

get '/' do
  'I can have a landing page too!'
end

############################ TEST ON LOCALHOST #################################

# 1. Have both Heroku CLI and ngrok
# 2. Run 'heroku local' from console, it will load Puma on port 5000
# 3. Expose port 5000 to the Internet with 'ngrok http 5000'
# 4. Provide your ngrok http_s_(!) address in Facebook Developer Dashboard
#    for webhook validation.
# 5. Open Messenger and talk to your bot!

# P.S. While you have DEBUG environment variable set to "true" (default in .env)
# All StandardError exceptions will go to the message dialog instead of
# breaking the server.
