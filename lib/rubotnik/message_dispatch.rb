require 'rubotnik/helpers'
require 'rubotnik/commands'

# TODO: Remove debugging statements or enable some kind of global Logging toggle
module Rubotnik
  # Routing for messages
  class MessageDispatch
    include Rubotnik::Helpers
    include Commands

    def initialize(message)
      @message = message
      p @message.class
      p @message
      @user = UserStore.instance.find_or_create_user(@message.sender['id'])
    end

    def route(&block)
      if @user.current_command
        command = @user.current_command
        execute(command)
        puts "Command #{command} is executed for user #{@user.id}" # log
      else
        bind_commands(&block)
      end
    end

    private

    def bind_commands(&block)
      @matched = false
      instance_eval(&block)
    end

    def bind(*regex_strings, all: false, to: nil, send_message: {})
      regexps = regex_strings.map { |rs| /\b#{rs}/i }
      proceed = regexps.any? { |regex| @message.text =~ regex }
      proceed = regexps.all? { |regex| @message.text =~ regex } if all
      return unless proceed
      @matched = true
      if block_given?
        yield
        return
      end
      handle_command(to, send_message)
    end

    # TODO: Update README to use send_message
    def handle_command(to, send_message)
      if send_message.empty?
        puts "Command #{to} is executed for user #{@user.id}"
        execute(to)
        @user.reset_command
        puts "Command is reset for user #{@user.id}"
      else
        say(send_message[:text], quick_replies: send_message[:quick_replies])
        @user.assign_command(to)
        puts "Command #{to} is set for user #{@user.id}"
      end
    end

    def default
      return if @matched
      puts 'None of the commands were recognized' # log
      yield
      @user.reset_command
    end

    def execute(command)
      method(command).call
    end
  end
end
