require 'rubotnik/version'
require 'rubotnik/message_dispatch'
require 'rubotnik/user_store'
require 'rubotnik/user'
require 'rubotnik/cli'
require 'facebook/messenger'
require 'ui/fb_button_template'
require 'ui/fb_carousel'
require 'ui/image_attachment'
require 'ui/quick_replies'
require 'sinatra'
include Facebook::Messenger

module Rubotnik
  def self.subscribe(token)
    Facebook::Messenger::Subscriptions.subscribe(access_token: token)
  end

  # TODO: ROUTING FOR POSTBACKS
  def self.route(event, &block)
    Bot.on event do |message|
      Rubotnik::MessageDispatch.new(message).route(&block)
    end
  end

  # TESTING
  def self.root
    Dir.pwd
  end

  def self.ui_test
    p UI.class
  end
end
