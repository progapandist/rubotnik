require 'dotenv/load' # comment this line out before pushing to Heroku!
require 'facebook/messenger'
require_relative 'persistent_menu'
require_relative 'greetings' # TODO: Change name
require_relative 'rubotnik' # TESTING
include Facebook::Messenger

# IMPORTANT! Subcribe your bot to your page
Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])

# THESE TWO SHOULD BE INSIDE Rubotnik module too.
PersistentMenu.enable
Greetings.enable

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

# Builds a quick reply that prompts location from user
LOCATION_PROMPT = UI::QuickReplies.location

IDIOMS = {
  not_found: 'There were no results. Type your destination again, please',
  ask_location: 'Type in any destination or send us your location:',
  unknown_command: "Sorry, I did not recognize your command",
  menu_greeting: 'Here are some suggestions for you:'
}

questionnaire_replies = UI::QuickReplies.build(["Yes", "START_QUESTIONNAIRE"],
                                               ["No", "STOP_QUESTIONNAIRE"])
questionnaire_welcome = "Welcome to the sample questionnaire! Are you ready?"

# Routing for messages
Bot.on :message do |message|
  Rubotnik.route(message) do

    # Will only be executed once until user deletes the chat and reconnects.
    # Use block to provide more complex functionality.
    greet "Hello and welcome!"

    # Use with 'to:' syntax to bind to a command found inside Commands
    # or associated modules.
    bind "carousel", to: :show_carousel

    # Use with block if you want to provide response behaviour
    # directly without looking for an existing command inside Commands.
    bind "fuck" do
      say("Fuck yourself!")
    end

    # Use with 'to:' and 'start_thread:' to point to the first command in a thread.
    # Thread should be located in Commands or a separate module mixed into Commands.
    # Include nested hash to provide a message asking user for input to the next command.
    # You can also pass an array of quick replies (you will have to process them
    # inside the thread).
    bind "button", to: :show_button_template

    # TODO: check_payload: true to check both text AND payload for a quick reply
    # useful when the binded command is a popular word
    # If you use that option, your command will ONLY be triggered when
    # the user hits the quick reply button. 
    bind "where", to: :lookup_location, check_payload: "LOCATION", start_thread: {
                                             message: "Le me know your location",
                                             quick_replies: LOCATION_PROMPT
                                           }

    bind 'questionnaire', to: :start_questionnaire, start_thread: {
                                                      message: questionnaire_welcome,
                                                      quick_replies: questionnaire_replies
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
  Rubotnik.route(postback) do

    bind "START" do
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
                                             message: "Le me know your location",
                                             quick_replies: LOCATION_PROMPT
                                           }

   bind "QUESTIONNAIRE", to: :start_questionnaire, start_thread: {
                                                      message: questionnaire_welcome,
                                                      quick_replies: questionnaire_replies
                                                    }

  end
end

# p postback.class # debug
# sender_id = postback.sender['id']
# user = UserStore.instance.find(sender_id) || UserStore.instance.add(User.new(sender_id))
# user.greet # we don't need a greeting with postbacks, so greet by default
# case postback.payload
# when 'START' then display_hints(COMMANDS_HINTS)
# when 'COORDINATES'
#   say(user, IDIOMS[:ask_location], LOCATION_PROMPT)
#   user.set_command(:show_coordinates)
# when 'FULL_ADDRESS'
#   say(user, IDIOMS[:ask_location], LOCATION_PROMPT)
#   user.set_command(:show_full_address)
# when 'LOCATION'
#   say(user, IDIOMS[:ask_location], LOCATION_PROMPT)
#   user.set_command(:lookup_location)
# when 'BUTTON_TEMPLATE_ACTION'
#   say(user, "Voila! You triggered an action and got some response!")
# when 'QUESTIONNAIRE'
#   user.set_command(:start_questionnaire)
#   replies = UI::QuickReplies.build(["Yes", "START_QUESTIONNAIRE"],
#                                          ["No", "STOP_QUESTIONNAIRE"])
#   say(user, "Welcome to the sample questionnaire! Are you ready?", replies)
# when 'SQUARE_IMAGES'
#   Commands::show_carousel(postback, user, image_ratio: :square)
#   user.reset_command # UNTESTED
# when 'HORIZONTAL_IMAGES'
#   Commands::show_carousel(postback, user)
#   user.reset_command # UNTESTED
# end

# Testing API integration. Works!
post "/incoming" do
  begin
    sender_id = params['id']
    user = UserStore.instance.find_or_create_user(sender_id)
    say("You got a message: #{params['message']}", user: user)
  rescue
    p "User not recognized or not available at the time"
  end
end
