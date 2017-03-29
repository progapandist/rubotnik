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
include Commands

# IMPORTANT! Subcribe your bot to your page
Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])
PersistentMenu.enable
Greetings.enable

MENU_REPLIES = [
  {
    content_type: 'text',
    title: 'GPS for address',
    payload: 'COORDINATES'
  },
  {
    content_type: 'text',
    title: 'Full address',
    payload: 'FULL_ADDRESS'
  },
  {
    content_type: 'text',
    title: 'My location',
    payload: 'LOCATION'
  }
]

IDIOMS = {
  not_found: 'There were no results. Type your destination again, please',
  ask_location: 'Type in any destination or send us your location:',
  unknown_command: 'Sorry, I did not recognize your command',
  menu_greeting: 'What do you want to look up?'
}

TYPE_LOCATION = [{ content_type: 'location' }]

Bot.on :message do |message|
  # p message
  # p message.quick_reply if message.quick_reply

  # create or find user on first connect
  sender_id = message.sender['id']
  user = UserStore.instance.find(sender_id) || UserStore.instance.add(User.new(sender_id))
  dispatcher = MessageDispatcher.new(user, message)
  dispatcher.dispatch
end

# Logic for postbacks
Bot.on :postback do |postback|
  sender_id = postback.sender['id']
  user = UserStore.instance.find(sender_id) || UserStore.instance.add(User.new(sender_id))
  user.greet # we don't need a greeting with postbacks
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
  end
end
