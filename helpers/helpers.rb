require 'httparty'
require 'json'

# Place for methods that make your life easier.
# They can be called from anywhere inside the common namespace.
module Helpers
  # State 'module_function' before any method definitions so
  # commands are mixed into Dispatch classes as private methods.
  module_function

  GRAPH_URL = 'https://graph.facebook.com/v2.8/'.freeze

  # abstraction over Bot.deliver to send messages declaratively and directly
  def say(text = 'What was I talking about?', quick_replies: nil, user: @user)
    message_options = {
      recipient: { id: user.id },
      message: { text: text }
    }
    message_options[:message][:quick_replies] = quick_replies if quick_replies
    Bot.deliver(message_options, access_token: ENV['ACCESS_TOKEN'])
  end

  def next_command(command)
    @user.assign_command(command)
  end

  def stop_thread
    @user.reset_command
  end

  def text_message?
    @message.respond_to?(:text) && !@message.text.nil?
  end

  def message_contains_location?
    @message.attachments && @message.attachments.first['type'] == 'location'
  end

  # Get user info from Graph API. Takes names of required fields as symbols
  # https://developers.facebook.com/docs/graph-api/reference/v2.2/user
  def get_user_info(*fields)
    str_fields = fields.map(&:to_s).join(',')
    url = GRAPH_URL + @user.id + '?fields=' + str_fields + '&access_token=' +
          ENV['ACCESS_TOKEN']
    begin
      return call_graph_api(url)
    rescue
      puts "Couldn't access URL" # logging
      return false
    end
  end

  def call_graph_api(url)
    @message.typing_on
    response = HTTParty.get(url)
    @message.typing_off
    case response.code
    when 200
      puts "User data received from Graph API: #{response.body}" # logging
      return JSON.parse(response.body, symbolize_names: true)
    else
      return false
    end
  end
end
