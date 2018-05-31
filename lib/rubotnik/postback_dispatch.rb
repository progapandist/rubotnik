require 'rubotnik/helpers'
require 'rubotnik/commands'

module Rubotnik
  # Routing for postbacks
  class PostbackDispatch
    include Rubotnik::Helpers
    include Commands

    attr_reader :postback, :user

    def initialize(postback)
      @postback = postback
      p @postback.class
      p @postback
      @user = Rubotnik::UserStore.instance.find_or_create_user(@postback.sender['id'])
    end

    def route(&block)
      @matched = false
      instance_eval(&block)
    rescue StandardError => error
      raise unless ENV["DEBUG"] == "true"
      stop_thread
      say "There was an error: #{error}"
    end

    private

    def bind(regex_string, to: nil, reply_with: {})
      return unless @postback.payload == regex_string.upcase
      clear_user_state
      @matched = true
      puts "Matched #{regex_string} to #{to.nil? ? 'block' : to}"
      if block_given?
        yield
        return
      end
      handle_commands(to, reply_with)
    end

    def handle_commands(to, reply_with)
      if reply_with.empty?
        execute(to)
        puts "Command #{to} is executed for user #{@user.id}"
        @user.reset_command
        puts "Command is reset for user #{@user.id}"
      else
        say(reply_with[:message], quick_replies: reply_with[:quick_replies])
        @user.assign_command(to)
        puts "Command #{to} is set for user #{@user.id}"
      end
    end

    def clear_user_state
      @user.reset_command # Stop any current interaction
      @user.session = {} # Reset whatever you stored in the user
    end

    def execute(command)
      method(command).call
    end
  end
end
