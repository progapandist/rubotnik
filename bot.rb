require 'dotenv/load' # comment this line out before pushing to Heroku!
require 'facebook/messenger'
require 'addressable/uri'
require 'httparty'
require 'json'
require_relative 'persistent_menu'
require_relative 'greetings'
require_relative 'user'
require_relative 'user_store'
require_relative 'message_dispatcher'
require_relative 'command_parser'
require_relative 'bot_helpers'
require_relative 'commands'
include Facebook::Messenger

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
].freeze

IDIOMS = {
  not_found: 'There were no results. Type your destination again, please',
  ask_location: 'Type in any destination or send us your location:',
  unknown_command: 'Sorry, I did not recognize your command',
  menu_greeting: 'What do you want to look up?'
}.freeze

TYPE_LOCATION = [{ content_type: 'location' }]

Bot.on :message do |message|
  # create or find user on first connect
  sender_id = message.sender['id']
  user = UserStore.instance.find(sender_id) || UserStore.instance.add(User.new(sender_id))
  dispatcher = MessageDispatcher.new(user, message)
  dispatcher.dispatch
end

# Logic for postbacks
Bot.on :postback do |postback|
  sender_id = postback.sender['id']
  case postback.payload
  when 'START' then Commands::show_replies_menu(postback.sender['id'], MENU_REPLIES)
  when 'COORDINATES'
    say(sender_id, IDIOMS[:ask_location], TYPE_LOCATION)
    show_coordinates(sender_id)
  when 'FULL_ADDRESS'
    say(sender_id, IDIOMS[:ask_location], TYPE_LOCATION)
    show_full_address(sender_id)
  when 'LOCATION'
    lookup_location(sender_id)
  end
end
