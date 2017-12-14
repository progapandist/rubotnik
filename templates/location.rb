module Commands
  API_URL = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='.freeze

  # Lookup based on location data from user's device
  def lookup_location
    if message_contains_location?
      handle_user_location
    else
      say("Please try your request again and use 'Send location' button")
    end
    stop_thread
  end

  def handle_user_location
    coords = message.attachments.first['payload']['coordinates']
    lat = coords['lat']
    long = coords['long']
    message.typing_on
    parsed = get_parsed_response(API_URL, "#{lat},#{long}")
    address = extract_full_address(parsed)
    say "Coordinates of your location: Latitude #{lat}, Longitude #{long}. " \
        "Looks like you're at #{address}"
    message.typing_off
  end

  # Talk to API
  def get_parsed_response(url, query)
    response = HTTParty.get(url + query)
    parsed = JSON.parse(response.body)
    parsed['status'] != 'ZERO_RESULTS' ? parsed : nil
  end

  def extract_full_address(parsed)
    parsed['results'].first['formatted_address']
  end
end
