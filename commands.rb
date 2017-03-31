require 'addressable/uri'
require 'httparty'
require 'json'
require_relative "bot_helpers"
require_relative "ui"
require_relative "quick_replies"
require_relative "sample_elements"
require_relative "questionnaire"
require_relative "show_ui_examples"

# RULES:
# commands assigned as part of conversation thread
# (through User#set_command in MessageDispatcher)
# should follow (message, user) convention for arguments

# Examples:
# - API call with a set of quick replies
# + Carousel with several items (Nic Cage)
# - Generic template
# - List template
# - API call involving location sharing
# + Questionnaire (store bits of data in user model, assign long sequence of commands one after another in a separate module)
# Double some commands in postbacks

module Commands
  # Include modules for helpers and separate threads
  include BotHelpers
  include Questionnaire
  include ShowUIExamples

  API_URL = 'https://maps.googleapis.com/maps/api/geocode/json?address='.freeze
  REVERSE_API_URL = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='.freeze

  # TODO: Move to ShowUIExamples module 
  def show_carousel(id, opts = {})
    if opts.key?(:image_ratio) && opts[:image_ratio] == :square
      UI::FBCarousel.new(SampleElements::CAROUSEL).square_images.send(id)
    else
      UI::FBCarousel.new(SampleElements::CAROUSEL).send(id)
    end
  end

  # Coordinates lookup
  def show_coordinates(message, user)
    if message_contains_location?(message)
      handle_user_location(message, user)
    else
      if !is_text_message?(message)
        say(user, "Why are you trying to fool me, human?")
      else
        handle_coordinates_lookup(message, user)
      end
    end
    user.reset_command
  end

  def handle_coordinates_lookup(message, user)
    query = encode_ascii(message.text)
    parsed_response = get_parsed_response(API_URL, query)
    message.type # let user know we're doing something
    if parsed_response
      coord = extract_coordinates(parsed_response)
      text = "Latitude: #{coord['lat']} / Longitude: #{coord['lng']}"
      say(user, text)
    else
      message.reply(text: IDIOMS[:not_found])
      show_coordinates(message, user)
    end
  end

  # Display a set of quick replies that serves as a menu
  def show_replies_menu(user, quick_replies)
    say(user, IDIOMS[:menu_greeting], quick_replies)
    user.engage unless user.engaged?
  end

  def greet_user(user)
    say(user, "Hello, dear new user!")
    user.greet
  end

  def message_contains_location?(message)
    if attachments = message.attachments
      attachments.first['type'] == 'location'
    else
      false
    end
  end

  # Lookup based on location data from user's device
  def lookup_location(message, user)
    if message_contains_location?(message)
      handle_user_location(message, user)
    else
      say(user, "Please try your request again and use 'Send location' button")
    end
    user.reset_command # should we reset command inside a command object?
  end

  def handle_user_location(message, user)
    coords = message.attachments.first['payload']['coordinates']
    lat = coords['lat']
    long = coords['long']
    message.type
    # make sure there is no space between lat and lng
    parsed = get_parsed_response(REVERSE_API_URL, "#{lat},#{long}")
    address = extract_full_address(parsed)
    say(user, "Coordinates of your location: Latitude #{lat}, Longitude #{long}. Looks like you're at #{address}")
  end

  # Full address lookup
  def show_full_address(message, user)
    if message_contains_location?(message)
      handle_user_location(message, user)
    else
      if !is_text_message?(message)
        say(user, "Why are you trying to fool me, human?")
        wait_for_any_input
      else
        handle_address_lookup(message, user)
      end
    end
    user.reset_command # should we reset command inside a command object?
  end

  def handle_address_lookup(message, user)
    query = encode_ascii(message.text)
    parsed_response = get_parsed_response(API_URL, query)
    message.type # let user know we're doing something
    if parsed_response
      full_address = extract_full_address(parsed_response)
      say(user, full_address)
    else
      message.reply(text: IDIOMS[:not_found])
      show_full_address(message, user)
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
end
