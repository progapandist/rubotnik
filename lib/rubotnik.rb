require 'rubotnik/version'
require 'rubotnik/message_dispatch'
require 'rubotnik/postback_dispatch'
require 'rubotnik/user_store'
require 'rubotnik/user'
require 'rubotnik/cli'
require 'rubotnik/generator'
require 'rubotnik/autoloader'
require 'ui/fb_button_template'
require 'ui/fb_carousel'
require 'ui/image_attachment'
require 'ui/quick_replies'
require 'sinatra'
require 'facebook/messenger'
include Facebook::Messenger
# TODO: Nest UI inside Rubotnik

module Rubotnik
  def self.subscribe(token)
    Facebook::Messenger::Subscriptions.subscribe(access_token: token)
  end

  # TODO: ROUTING FOR POSTBACKS
  def self.route(event, debug: false, &block)
    Bot.on(event, &block) unless [:message, :postback].include?(event) # TODO: Test
    Bot.on event do |e|
      case e
      when Facebook::Messenger::Incoming::Message
        Rubotnik::MessageDispatch.new(e).route(&block)
      when Facebook::Messenger::Incoming::Postback
        Rubotnik::PostbackDispatch.new(e).route(&block)
      end
    end
  rescue StandardError => error
    raise unless debug
    say "There was an error: #{error}"
  end

  # TODO seems to work, test again and update README
  def self.set_profile(*payloads)
    payloads.each do |payload|
      Facebook::Messenger::Profile.set(payload, access_token: ENV['ACCESS_TOKEN'])
    end
  end
end
