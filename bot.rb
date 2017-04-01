require 'dotenv/load' # comment this line out before pushing to Heroku!
require 'facebook/messenger'
require_relative 'persistent_menu'
require_relative 'greetings'
require_relative 'user'
require_relative 'user_store'
require_relative 'message_dispatcher'
require_relative 'bot_helpers'
require_relative 'commands'
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

# NOTE: Should be called with a splat operator if a set of quick replies is a pre-formed array
MENU_REPLIES = UI::QuickReplies.new(*replies_for_menu).build

IDIOMS = {
  not_found: 'There were no results. Type your destination again, please',
  ask_location: 'Type in any destination or send us your location:',
  unknown_command: 'Sorry, I did not recognize your command',
  menu_greeting: 'What do you want to look up?'
}

TYPE_LOCATION = [{ content_type: 'location' }]

Bot.on :message do |message|
  # create or find user on first connect
  sender_id = message.sender['id']
  # TODO: Refactor as find_or_add_user
  user = UserStore.instance.find(sender_id) || UserStore.instance.add(User.new(sender_id))
  dispatcher = MessageDispatcher.new(user, message) # TODO: Should be a class method?
  dispatcher.dispatch
end

# TODO: Implement dispatcher class for postbacks
Bot.on :postback do |postback|
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
    replies = UI::QuickReplies.new(["Yes", "START_QUESTIONNAIRE"],
                                           ["No", "STOP_QUESTIONNAIRE"]).build
    say(user, "Welcome to the sample questionnaire! Are you ready?", replies)
  when 'SQUARE_IMAGES'
    Commands::show_carousel(postback, user, image_ratio: :square)
    user.disengage
  when 'HORIZONTAL_IMAGES'
    Commands::show_carousel(postback, user)
    user.disengage
  end
end
