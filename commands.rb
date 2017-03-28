require_relative "bot_helpers"
require_relative "ui_elements"

# Examples:
# - API call with quick replies
# - Carousel with several items (Nic Cage)
# - Generic template
# - Receipt template?
# - Airline template?
# - API call involving location sharing
# - Questionnaire (store bits of data in user model, assign long sequence of commands one after another in a separate module)
# Double all commands in postbacks 

module Commands
  include BotHelpers

  API_URL = 'https://maps.googleapis.com/maps/api/geocode/json?address='.freeze
  REVERSE_API_URL = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='.freeze

  TEST_CAROUSEL_DATA = [
                          {
                          title: "Item 1",
                          # Horizontal image should have 1.91:1 ratio
                          image_url: "https://www.placecage.com/382/200",
                          subtitle: "It's a first item!",
                          buttons: [
                              { type: :web_url,
                              url: "https://google.com",
                              title: "Go to website" },
                              { type: :postback,
                                title: "Trigger postback",
                                payload: "CAROUSEL_PAYLOAD_ONE"
                              }
                            ]
                          },
                          {
                          title: "Item 2",
                          # Horizontal image should have 1.91:1 ratio
                          image_url: "https://www.placecage.com/470/250",
                          subtitle: "A second item...",
                          buttons: [
                              { type: :web_url,
                              url: "https://google.com",
                              title: "Go to website" },
                              { type: :postback,
                                title: "Trigger postback",
                                payload: "CAROUSEL_PAYLOAD_TWO"
                              }
                            ]
                          }
                        ]

  def show_carousel(id)
    UIElements::FBCarousel.new(TEST_CAROUSEL_DATA).send(id)
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
