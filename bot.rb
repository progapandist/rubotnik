# require 'dotenv/load' # NOTE: comment this line out before pushing to Heroku!
require 'facebook/messenger'
require_relative 'persistent_menu'
require_relative 'greetings' # TODO: Change name. no need to require separately from Rubotnik module?
require_relative 'rubotnik'
require_relative 'commands'
include Facebook::Messenger
# Include Commands on top level to mix commands, threads and helpers
# into common namespace.
include Commands


# IMPORTANT! Subcribe your bot to your page
Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])

# THESE TWO SHOULD BE INSIDE Rubotnik module too.
PersistentMenu.enable
Rubotnik::Greetings.enable

IDIOMS = {
  not_found: 'There were no results. Type your destination again, please',
  ask_location: 'Type in any destination or send us your location:',
  unknown_command: "Sorry, I did not recognize your command",
  menu_greeting: 'Here are some suggestions for you:'
}

replies_for_menu =  [
                      {
                        title: 'Where I am at?',
                        payload: 'LOCATION'
                      },
                      {
                        title: 'Take questionnaire',
                        payload: 'QUESTIONNAIRE'
                      }
                    ]

# NOTE: QuickReplies.build should be called with a splat operator if a set of quick replies is a pre-formed array
COMMANDS_HINTS = UI::QuickReplies.build(*replies_for_menu)

# Build a quick reply that prompts location from user
LOCATION_PROMPT = UI::QuickReplies.location

# Define vartiables you want to use for both messages and postbacks
# outside both Bot.on method calls.
questionnaire_replies = UI::QuickReplies.build(["Yes", "START_QUESTIONNAIRE"],
                                               ["No", "STOP_QUESTIONNAIRE"])
questionnaire_welcome = "Welcome to the sample questionnaire! Are you ready?"

# Routing for messages
Bot.on :message do |message|
  # Use DSL inside the block passed to Rubotnik.route(message)
  Rubotnik::MessageDispatch.new(message).route do

    # Will only be executed once until user deletes the chat and reconnects.
    # Use block to do more than just send a text message.
    greet "Hello and welcome!"

    # Use with 'to:' syntax to bind to a command found inside Commands
    # or its sub-modules.
    bind "carousel", to: :show_carousel

    bind "button", to: :show_button_template

    bind "facebook data" do
      get_user_info(:first_name, :last_name)
    end

    # Use with block if you want to provide response behaviour
    # directly without looking for an existing command inside Commands.
    bind "knock" do
      say "Who's there?"
    end

    # Use with 'to:' and 'start_thread:' to point to the first command in a thread.
    # Thread should be located in Commands or a separate module mixed into Commands.
    # Include nested hash to provide a message asking user for input to the next command.
    # You can also pass an array of quick replies (you will have to process them
    # inside the thread).
    bind 'questionnaire', to: :start_questionnaire, start_thread: {
                                                      message: questionnaire_welcome,
                                                      quick_replies: questionnaire_replies
                                                    }

    # Use check_payload: "STRING" option to check both text AND payload
    # tied to  quick reply. Useful when the binded command is a popular word
    # If you use that option, your command will ONLY be triggered when
    # the user hits the quick reply button.
    bind "where", to: :lookup_location,
                  check_payload: "LOCATION",
                  start_thread: {
                                  message: "Let me know your location",
                                  quick_replies: LOCATION_PROMPT
                                }

    # Falback action if none of the commands matched the input,
    # NB: Should always come last. Takes a block.
    unrecognized do
      say IDIOMS[:menu_greeting], quick_replies: COMMANDS_HINTS
    end

  end
end

# Routing for postbacks
Bot.on :postback do |postback|
  Rubotnik::PostbackDispatch.new(postback).route do

    bind "START" do
      say "Hello and welcome!"
      @user.greet # greet user when she starts from welcome screen
      say IDIOMS[:menu_greeting], quick_replies: COMMANDS_HINTS
    end

    # Use block syntax when a command takes an argument rather
    # than 'message' or 'user' (which are accessible from everyhwere
    # as instance variables, no need to pass them around).
    bind "SQUARE_IMAGES" do
      show_carousel(image_ratio: :square)
    end

    # No custom parameter passed, can use simplified syntax
    bind "HORIZONTAL_IMAGES", to: :show_carousel

    bind "LOCATION", to: :lookup_location, start_thread: {
                                             message: "Let me know your location",
                                             quick_replies: LOCATION_PROMPT
                                           }

   bind "QUESTIONNAIRE", to: :start_questionnaire, start_thread: {
                                                      message: questionnaire_welcome,
                                                      quick_replies: questionnaire_replies
                                                    }

  end
end

# Testing API integration. Use regular Sintatra syntax to define endpoints.
post "/incoming" do
  begin
    sender_id = params['id']
    user = UserStore.instance.find_or_create_user(sender_id)
    say("You got a message: #{params['message']}", user: user)
  rescue
    p "User not recognized or not available at the time"
  end
end
