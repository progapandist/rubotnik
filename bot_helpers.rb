require 'httparty'

# Place for methods that abstract over facebook-messenger API
module BotHelpers
  GRAPH_URL = "https://graph.facebook.com/v2.8/"

  # abstraction over Bot.deliver to send messages declaratively and directly
  def say(text = "What was I talking about?", quick_replies: nil, user: @user)
    message_options = {
      recipient: { id: user.id },
      message: { text: text }
    }
    if quick_replies
      message_options[:message][:quick_replies] = quick_replies
    end
    Bot.deliver(message_options, access_token: ENV['ACCESS_TOKEN'])
  end

  def next_command(command)
    @user.set_command(command)
  end

  def stop_commands
    @user.reset_command
  end

  def text_message?
    @message.respond_to?(:text) && !@message.text.nil?
  end

  # TODO: In progress
  # Get user info from Graph API. Takes names of required fields as symbols
  # https://developers.facebook.com/docs/graph-api/reference/v2.2/user
  def get_user_info(*fields)
    str_fields = fields.map(&:to_s).join(",")
    url = GRAPH_URL + @user.id + "?fields=" + str_fields + "&access_token=" +
          ENV["ACCESS_TOKEN"]
    begin
      response = HTTParty.get(url)
      # TODO: Switch on response.code
      puts response.body, response.code, response.message, response.headers.inspect
    rescue
      puts "Couldn't access URL" # logging
      return ""
    end
  end

end
