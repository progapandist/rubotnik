module Rubotnik
  class MessageDispatch
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

    # TODO: Refactor for readability and shortness
    def bind(*regex_strings, all: false, to: nil, start_thread: {}, check_payload: '')
      regexps = regex_strings.map { |rs| /#{rs}/i }

      if all
        proceed = regexps.all? { |regex| @message.text =~ regex }
      else
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
