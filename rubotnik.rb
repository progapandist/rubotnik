module Rubotnik

  class Router
    def self.route(message, &block)
      # Logging
      p message
      p message.class
      # Logic
      @user = UserStore.instance.find_or_create_user(message.sender['id'])
      dispatch(message, &block)
    end

    private_class_method def self.dispatch(message, &block)
      if @user.current_command
        command = @user.current_command
        # NB: commands should exist under the same namespace as Rubotnik in order to call them
        method(command).call(message, @user) # TODO: Don't need to pass user anymore or make it optional!
        puts "Command #{command} is executed for user #{@user.id}" # log
      else
        # We only greet user once for the whole interaction
        # TODO: This shouldnt' be hardcoded, greeting should be implemented in the DSL
        greet_user(@user) unless @user.greeted?
        puts "User #{@user.id} does not have a command assigned yet" # log
        Rubotnik::Parser.bind_commands(message, @user, &block)
      end
    end

  end

  class Parser
    def self.bind_commands(message, user, &block)
      @message = message
      @user = user
      @matched = false
      class_eval(&block)
    end

    private_class_method def self.bind(regex_string, to: nil, start_thread: {})
      proceed = (@message.respond_to?(:text) && @message.text =~ /#{regex_string}/i) ||
                (@message.respond_to?(:payload) && @message.payload == regex_string)
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

    # TODO: TEST WITHOUT AN ARGUMENT
    private_class_method def self.not_recognized
      unless @matched
        puts "not_recognized triggered" # debug
        yield
        @user.reset_command
      end
    end

    # TODO: use "send" instead of "call"?
    private_class_method def self.execute(command)
      method(command).call(@message, @user)
    end
  end
end
