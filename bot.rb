require 'dotenv/load' # comment this line out before pushing to Heroku!
require 'facebook/messenger'
require 'addressable/uri'
require 'httparty'
require 'json'
require_relative 'persistent_menu'
require_relative 'greetings'
require_relative 'user'
require_relative 'user_store'
include Facebook::Messenger

# IMPORTANT! Subcribe your bot to your page
Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])
PersistentMenu.enable
Greetings.enable

API_URL = 'https://maps.googleapis.com/maps/api/geocode/json?address='.freeze
REVERSE_API_URL = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='.freeze

IDIOMS = {
  not_found: 'There were no results. Type your destination again, please',
  ask_location: 'Type in any destination or send us your location:',
  unknown_command: 'Sorry, I did not recognize your command',
  menu_greeting: 'What do you want to look up?'
}.freeze

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

TYPE_LOCATION = [{ content_type: 'location' }]


# Logic for postbacks
Bot.on :postback do |postback|
  sender_id = postback.sender['id']
  case postback.payload
  when 'START' then show_replies_menu(postback.sender['id'], MENU_REPLIES)
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

def dispatch
  Bot.on :message do |message|
    # create or find user on first connect
    sender_id = message.sender['id']
    user = UserStore.instance.find(sender_id) || UserStore.instance.add(User.new(sender_id))
    p user
    if user.command.nil?
      show_replies_menu(user.id, MENU_REPLIES)
      case message.text
      when /coord/i, /gps/i
        say(sender_id, IDIOMS[:ask_location], TYPE_LOCATION)
        user.set_command(:show_coordinates)
      else
        user.set_command(:unknown_command)
      end
    else
      command = user.command
      method(command).call(message, user.id)
      user.reset_command
      dispatch
    end
  end
end

dispatch

def unknown_command(message = "", sender_id)
  say(sender_id, IDIOMS[:unknown_command])
  show_replies_menu(sender_id, MENU_REPLIES)
end

# Coordinates lookup
def show_coordinates(message, id)
  if message_contains_location?(message)
    handle_user_location(message)
  else
    if !is_text_message?(message)
      say(id, "Why are you trying to fool me, human?")
      wait_for_any_input
    else
      handle_coordinates_lookup(message, id)
    end
  end
end

def handle_coordinates_lookup(message, id)
  query = encode_ascii(message.text)
  parsed_response = get_parsed_response(API_URL, query)
  message.type # let user know we're doing something
  if parsed_response
    coord = extract_coordinates(parsed_response)
    text = "Latitude: #{coord['lat']} / Longitude: #{coord['lng']}"
    say(id, text)
    wait_for_any_input
  else
    message.reply(text: IDIOMS[:not_found])
    show_coordinates(id)
  end
end


# Logic for quick replies and text commands
def wait_for_command
  Bot.on :message do |message|
    puts "Received '#{message.inspect}' from #{message.sender}" # debug only
    sender_id = message.sender['id']
    case message.text
    when /coord/i, /gps/i
      say(sender_id, IDIOMS[:ask_location], TYPE_LOCATION)
      show_coordinates(sender_id)
    when /full ad/i # we got the user even the address is misspelled
      say(sender_id, IDIOMS[:ask_location], TYPE_LOCATION)
      show_full_address(sender_id)
    when /location/i
      lookup_location(sender_id)
    else
      message.reply(text: IDIOMS[:unknown_command])
      show_replies_menu(sender_id, MENU_REPLIES)
    end
  end
end

# Start conversation loop
def wait_for_any_input
  Bot.on :message do |message|
    puts "Received '#{message.inspect}' from #{message.sender}" # debug only
    if message_contains_location?(message)
      handle_user_location(message)
    else
      show_replies_menu(message.sender['id'], MENU_REPLIES)
    end
  end
end

# helper function to send messages declaratively and directly
def say(recipient_id, text, quick_replies = nil)
  message_options = {
  recipient: { id: recipient_id },
  message: { text: text }
  }
  if quick_replies
    message_options[:message][:quick_replies] = quick_replies
  end
  Bot.deliver(message_options, access_token: ENV['ACCESS_TOKEN'])
end

# Display a set of quick replies that serves as a menu
def show_replies_menu(id, quick_replies)
  say(id, IDIOMS[:menu_greeting], quick_replies)
end

def message_contains_location?(message)
  if attachments = message.attachments
    attachments.first['type'] == 'location'
  else
    false
  end
end

# Lookup based on location data from user's device
def lookup_location(sender_id)
  say(sender_id, 'Let me know your location:', TYPE_LOCATION)
  Bot.on :message do |message|
    if message.sender == sender_id
      if message_contains_location?(message)
        handle_user_location(message)
      else
        message.reply(text: "Please try your request again and use 'Send location' button")
      end
      wait_for_any_input
    end
  end
end

def handle_user_location(message)
  coords = message.attachments.first['payload']['coordinates']
  lat = coords['lat']
  long = coords['long']
  message.type
  # make sure there is no space between lat and lng
  parsed = get_parsed_response(REVERSE_API_URL, "#{lat},#{long}")
  address = extract_full_address(parsed)
  message.reply(text: "Coordinates of your location: Latitude #{lat}, Longitude #{long}. Looks like you're at #{address}")
  wait_for_any_input
end

# Full address lookup
def show_full_address(id)
  Bot.on :message do |message|
    if message_contains_location?(message)
      handle_user_location(message)
    else
      if !is_text_message?(message)
        say(id, "Why are you trying to fool me, human?")
        wait_for_any_input
      else
        handle_address_lookup(message, id)
      end
    end
  end
end

def handle_address_lookup(message, id)
  query = encode_ascii(message.text)
  parsed_response = get_parsed_response(API_URL, query)
  message.type # let user know we're doing something
  if parsed_response
    full_address = extract_full_address(parsed_response)
    say(id, full_address)
    wait_for_any_input
  else
    message.reply(text: IDIOMS[:not_found])
    show_full_address(id)
  end
end

# Talk to API
def get_parsed_response(url, query)
  response = HTTParty.get(url + query)
  parsed = JSON.parse(response.body)
  parsed['status'] != 'ZERO_RESULTS' ? parsed : nil
end

def encode_ascii(s)
  Addressable::URI.parse(s).normalize.to_s
end

def is_text_message?(message)
  !message.text.nil?
end


def extract_coordinates(parsed)
  parsed['results'].first['geometry']['location']
end

def extract_full_address(parsed)
  parsed['results'].first['formatted_address']
end

# # launch the loop
# wait_for_any_input
