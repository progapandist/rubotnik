require_relative 'user_store'

module Rubotnik

  # POSTBACKS

  class PostbackDispatch
    def initialize(postback)
      @postback = postback
      @user = UserStore.instance.find_or_create_user(@postback.sender['id'])
    end

    def route(&block)
      @matched = false
      instance_eval(&block)
    end

    private

    def bind(regex_string, to: nil, start_thread: {})
      if @postback.payload == regex_string.upcase
        @user.reset_command # Stop any current interaction
        @user.answers = {} # Reset whatever you stored in the user
        @matched = true
        puts "Matched #{regex_string} to #{to.nil? ? 'block' : to}"
        if block_given?
          yield
          return
        end
        if start_thread.empty?
          execute(to)
          puts "Command #{to} is executed for user #{@user.id}"
          @user.reset_command
          puts "Command is reset for user #{@user.id}"
        else
          say(start_thread[:message], quick_replies: start_thread[:quick_replies])
          @user.set_command(to)
          puts "Command #{to} is set for user #{@user.id}"
        end
      end
    end
    def execute(command)
      method(command).call
    end
  end

  # MESSAGES

  class MessageDispatch
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

    # TODO: Call the user by name
    # We only greet user once for the whole interaction
    def greet(text = "Hello")
      unless @user.greeted?
        if block_given?
          yield
        else
          say text
        end
        @user.greet
      end
    end

    def bind(*regex_strings, all: false, to: nil, start_thread: {}, check_payload: '')
      regexps = regex_strings.map { |rs| /#{rs}/i }

      if all == true
        proceed = regexps.all? { |regex| @message.text =~ regex }
      elsif all == false
        proceed = regexps.any? { |regex| @message.text =~ regex }
      end

      if check_payload.class == String && !check_payload.empty?
        proceed = proceed && @message.quick_reply == check_payload.upcase
      end

      if proceed
        @matched = true
        if block_given?
          yield
          return
        end
        if start_thread.empty?
          execute(to)
          @user.reset_command
        else
          say(start_thread[:message], quick_replies: start_thread[:quick_replies])
          @user.set_command(to)
        end
      end
    end

    def unrecognized
      unless @matched
        puts "None of the commands were recognized" # log
        yield
        @user.reset_command
      end
    end

    def execute(command)
      method(command).call
    end
  end

end
