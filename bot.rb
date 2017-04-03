require 'dotenv/load' # comment this line out before pushing to Heroku!
require 'facebook/messenger'
require_relative 'persistent_menu'
require_relative 'greetings'
require_relative 'user'
require_relative 'user_store'
require_relative 'message_dispatcher'
require_relative 'bot_helpers'
require_relative 'commands'
require_relative 'rubotnik' # TESTING
include Facebook::Messenger
include Commands # TODO: Do I need this line?

# IMPORTANT! Subcribe your bot to your page
Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])
PersistentMenu.enable
Greetings.enable

replies_for_menu =  [
                      {
                        title: 'GPS for coordinates',
                        payload: 'COORDINATES'
                      },
                      {
                        title: 'Full address',
                        payload: 'FULL_ADDRESS'
                      },
                      {
                        title: 'My location',
                        payload: 'LOCATION'
                      }
                    ]

# NOTE: QuickReplies.build should be called with a splat operator if a set of quick replies is a pre-formed array
MENU_REPLIES = UI::QuickReplies.build(*replies_for_menu)

IDIOMS = {
  not_found: 'There were no results. Type your destination again, please',
  ask_location: 'Type in any destination or send us your location:',
  unknown_command: 'Sorry, I did not recognize your command',
  menu_greeting: 'What do you want to look up?'
}

# Builds a quick reply that prompts location from user
TYPE_LOCATION = UI::QuickReplies.location

# Rubotnik.dispatch should have different behaviour depending on
# what was passed as an argument: message or postback

Bot.on :message do |message|
  Rubotnik.dispatch(message) do
    # TESTING THE DSL ON SOME COMMANDS
    # Any string will be turned into case-insensitive regex pattern.
    # You can also provide regex directly.

    # Use with 'to:' syntax to bind to a command found inside Commands
    # or associated modules.
    bind "carousel", to: :show_carousel

    # Use with block if you want to provide response behaviour
    # directly without looking for an existing command inside Commands.
    bind "screw" do
      say(@user, "Screw yourself!")
    end

    # Use with 'to:' and 'start_thread:' to point to the first command in a thread.
    # Provide message asking input for the next command in the nested hash.
    # You can also pass an array of quick replies.
    bind "location", to: :lookup_location,
    start_thread: {
      message: "Le me know your location",
      quick_replies: TYPE_LOCATION
    }

    questionnaire_replies = UI::QuickReplies.build(["Yes", "START_QUESTIONNAIRE"],
    ["No", "STOP_QUESTIONNAIRE"])

    bind 'questionnaire', to: :start_questionnaire,
    start_thread: {
      message: "Welcome to the sample questionnaire! Are you ready?",
      quick_replies: questionnaire_replies
    }

    # Falback action if none of the commands matched the input,
    # NB: Should always come last. Takes a block.
    not_recognized do
      show_replies_menu(@user, MENU_REPLIES)
    end
  end
end

# Bot.on :message do |message|
#   p message.class # debug
#   # create or find user on first connect
#   sender_id = message.sender['id']
#
#   user = UserStore.instance.find(sender_id) || UserStore.instance.add(User.new(sender_id))
#   MessageDispatcher.dispatch(user, message)
# end

# TODO: Implement dispatcher class for postbacks
Bot.on :postback do |postback|
  p postback.class # debug
  sender_id = postback.sender['id']
  user = UserStore.instance.find(sender_id) || UserStore.instance.add(User.new(sender_id))
  user.greet # we don't need a greeting with postbacks, so greet by default
  case postback.payload
  when 'START' then show_replies_menu(user, MENU_REPLIES)
  when 'COORDINATES'
    say(user, IDIOMS[:ask_location], TYPE_LOCATION)
    user.set_command(:show_coordinates)
  when 'FULL_ADDRESS'
    say(user, IDIOMS[:ask_location], TYPE_LOCATION)
    user.set_command(:show_full_address)
  when 'LOCATION'
    say(user, IDIOMS[:ask_location], TYPE_LOCATION)
    user.set_command(:lookup_location)
  when 'BUTTON_TEMPLATE_ACTION'
    say(user, "Voila! You triggered an action and got some response!")
  when 'QUESTIONNAIRE'
    user.set_command(:start_questionnaire)
    replies = UI::QuickReplies.build(["Yes", "START_QUESTIONNAIRE"],
                                           ["No", "STOP_QUESTIONNAIRE"])
    say(user, "Welcome to the sample questionnaire! Are you ready?", replies)
  when 'SQUARE_IMAGES'
    Commands::show_carousel(postback, user, image_ratio: :square)
    user.reset_command # UNTESTED
  when 'HORIZONTAL_IMAGES'
    Commands::show_carousel(postback, user)
    user.reset_command # UNTESTED
  end
end
