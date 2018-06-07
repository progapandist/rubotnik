require 'rubotnik/version'
require 'rubotnik/message_dispatch'
require 'rubotnik/postback_dispatch'
require 'rubotnik/user_store'
require 'rubotnik/user'
require 'rubotnik/cli'
require 'rubotnik/generator'
require 'rubotnik/autoloader'
require 'ui/base_ui_element'
require 'ui/common/has_buttons'
require 'ui/fb_button_template'
require 'ui/fb_carousel'
require 'ui/fb_open_graph_template'
require 'ui/image_attachment'
require 'ui/quick_replies'
require 'sinatra'
require 'facebook/messenger'
include Facebook::Messenger

module Rubotnik
  def self.subscribe(token)
    Facebook::Messenger::Subscriptions.subscribe(access_token: token)
  end

  def self.route(event, &block)
    if [:message, :postback].include?(event)
      Bot.on event do |e|
        case e
        when Facebook::Messenger::Incoming::Message
          Rubotnik::MessageDispatch.new(e).route(&block)
        when Facebook::Messenger::Incoming::Postback
          Rubotnik::PostbackDispatch.new(e).route(&block)
        end
      end
    else
      Bot.on(event, &block)
    end
  end

  def self.set_profile(*payloads)
    payloads.each do |payload|
      Facebook::Messenger::Profile.set(payload, access_token: ENV['ACCESS_TOKEN'])
    end
  end
end
