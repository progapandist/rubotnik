require 'rubotnik/helpers'
require 'rubotnik/commands'

module Rubotnik
  # Routing for postbacks
  class PostbackDispatch
    include Rubotnik::Helpers
    include Commands

    def initialize(postback)
      @postback = postback
      p @postback.class
      p @postback
      @user = UserStore.instance.find_or_create_user(@postback.sender['id'])
    end

    def route(&block)
      @matched = false
      instance_eval(&block)
    end

    private

    def bind(regex_string, to: nil, send_message: {})
      return unless @postback.payload == regex_string.upcase
      clear_user_state # TODO: DO I NEED IT? 
      @matched = true
      puts "Matched #{regex_string} to #{to.nil? ? 'block' : to}"
      if block_given?
        yield
        return
      end
      handle_commands(to, send_message)
    end

    def handle_commands(to, send_message)
      if send_message.empty?
        execute(to)
        puts "Command #{to} is executed for user #{@user.id}"
        @user.reset_command
        puts "Command is reset for user #{@user.id}"
      else
        say(send_message[:message], quick_replies: send_message[:quick_replies])
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
