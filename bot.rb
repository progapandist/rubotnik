# rubocop:disable Metrics/BlockLength
# require 'dotenv/load' # leave this line commented while working with heroku
require 'facebook/messenger'
require 'sinatra'
require_relative 'rubotnik/rubotnik'
require_relative 'helpers/helpers'
include Facebook::Messenger
include Helpers # mixing helpers into the common namespace
# so they can be used outside of Dispatches

############# START UP YOUR BOT, SET UP GREETING AND MENU ###################

# NB: Subcribe your bot to your page here.
Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])

# Enable "Get Started" button, greeting and persistent menu for your bot
Rubotnik::BotProfile.enable
Rubotnik::PersistentMenu.enable

############################################################################

# NOTE: QuickReplies.build should be called with a splat operator
# if a set of quick replies is an array of arrays.
# e.g. UI::QuickReplies.build(*replies)
HINTS = UI::QuickReplies.build(['Where am I?', 'LOCATION'],
                               ['Take questionnaire', 'QUESTIONNAIRE'])

# Build a quick reply that prompts location from user
LOCATION_PROMPT = UI::QuickReplies.location

# Define vartiables you want to use for both messages and postbacks
# outside both Bot.on method calls.
questionnaire_replies = UI::QuickReplies.build(%w[Yes START_QUESTIONNAIRE],
                                               %w[No STOP_QUESTIONNAIRE])
questionnaire_welcome = 'Welcome to the sample questionnaire! Are you ready?'

####################### ROUTE MESSAGES HERE ################################

Bot.on :message do |message|
  # Use DSL inside the following block:
  Rubotnik::MessageDispatch.new(message).route do
    # All strings will be turned into case insensitive regular expressions.
    # If you pass a number of strings, any match will trigger a command,
    # unless 'all: true' flag is present. In that case, MessageDispatch
    # will expect all words to be present in a single message.

    # Use with 'to:' syntax to bind to a command found inside Commands
    # or its sub-modules.
    bind 'carousel', 'generic template', to: :show_carousel
    bind 'button', 'template', all: true, to: :show_button_template
    bind 'image', to: :send_image

    # bind also takes regexps directly
    bind(/my name/i, /mon nom/i) do
      user_info = get_user_info(:first_name)
      if user_info
        user_name = user_info[:first_name]
        say "Your name is #{user_name}!"
      else
        say 'I could not get your name, sorry :('
      end
    end

    # Use with block if you want to provide response behaviour
    # directly without looking for an existing command inside Commands.
    bind 'knock' do
      say "Who's there?"
    end

    bind 'hi', 'hello', 'yo', 'hey' do
      say "Nice to meet you! Here's what I can do", quick_replies: HINTS
    end

    # Use with 'to:' and 'start_thread:' to point to the first
    # command of a thread. Thread should be located in Commands
    # or a separate module mixed into Commands.
    # Include nested hash to provide a message asking user
    # for input to the next command. You can also pass an array of
    # quick replies (and process them inside the thread).
    bind 'questionnaire', to: :start_questionnaire, start_thread: {
      message: questionnaire_welcome,
      quick_replies: questionnaire_replies
    }

    bind 'where', 'am', 'I', all: true, to: :lookup_location, start_thread: {
      message: 'Let me know your location',
      quick_replies: LOCATION_PROMPT
    }

    # Falback action if none of the commands matched the input,
    # NB: Should always come last. Takes a block.
    default do
      say 'Here are some suggestions for you:', quick_replies: HINTS
    end
  end
end

######################## ROUTE POSTBACKS HERE ###############################

Bot.on :postback do |postback|
  Rubotnik::PostbackDispatch.new(postback).route do
    bind 'START' do
      say 'Hello and welcome!'
      say 'Here are some suggestions for you:', quick_replies: HINTS
    end

    bind 'CAROUSEL', to: :show_carousel
    bind 'BUTTON_TEMPLATE', to: :show_button_template
    bind 'IMAGE_ATTACHMENT', to: :send_image

    # Use block syntax when a command takes an argument rather
    # than 'message' or 'user' (which are accessible from everyhwere
    # as instance variables, no need to pass them around).
    bind 'BUTTON_TEMPLATE_ACTION' do
      say "I don't really do anything useful"
    end

    bind 'SQUARE_IMAGES' do
      show_carousel(image_ratio: :square)
    end

    # No custom parameter passed, can use simplified syntax
    bind 'HORIZONTAL_IMAGES', to: :show_carousel

    bind 'LOCATION', to: :lookup_location, start_thread: {
      message: 'Let me know your location',
      quick_replies: LOCATION_PROMPT
    }

    bind 'QUESTIONNAIRE', to: :start_questionnaire, start_thread: {
      message: questionnaire_welcome,
      quick_replies: questionnaire_replies
    }
  end
end

##### USE STANDARD SINATRA TO IMPLEMENT WEBHOOKS FOR OTHER SERVICES #######

# Example of API integration. Use regular Sintatra syntax to define endpoints.
post '/incoming' do
  begin
    sender_id = params['id']
    user = UserStore.instance.find_or_create_user(sender_id)
    say("You got a message: #{params['message']}", user: user)
  rescue
    p 'User not recognized or not available at the time'
  end
end

get '/' do
  'Nothing to look at'
end
