module Rubotnik

  class Router
    # TODO: Find better name than 'dispatch'
    # .handle? .route?
    def self.route(message, &block)
      p message.class # logging
      p message # logging
      # create or find user on first connect
      sender_id = message.sender['id']
      user = UserStore.instance.find_or_create_user(sender_id)
      MessageDispatcher.dispatch(user, message)
      Parser.bind_commands(message, user, &block)
    end
  end

  class MessageDispatcher
    def self.dispatch(user, message)
      @user = user
      @message = message

      # The main switch happens here:
      # user either has a threaded command set from previous interaction
      # or we go back to top level commands
      if @user.current_command
        command = @user.current_command
        method(command).call(@message, @user)
        puts "Command #{command} is executed for user #{@user.id}" # log
      else
        # We only greet user once for the whole interaction
        # TODO: This shouldnt' be hardcoded, greeting should be implemented in the DSL
        greet_user(@user) unless @user.greeted?
        puts "User #{@user.id} does not have a command assigned yet" # log
        parse_commands
      end
    end
  end

  class Parser
    @message, @user, @matched = nil

    def self.bind_commands(message, user, &block)
      @message = message
      @user = user
      @matched = false
      class_eval(&block)
    end

    def self.bind(regex_string, to: nil, start_thread: {})
      if @message.text =~ /#{regex_string}/i
        @matched = true
        if block_given?
          yield
          return
        end
        if start_thread.empty?
          execute(to)
          @user.reset_command
        else
          say(@user, start_thread[:message], start_thread[:quick_replies])
          @user.set_command(to)
        end
      end
    end

    # TODO: TEST WITHOUT AN ARGUMENT
    def self.not_recognized
      unless @matched
        puts "not_recognized triggered" # debug
        yield
        @user.reset_command
      end
    end

    # TODO: use "send" instead of "call"?
    def self.execute(command)
      method(command).call(@message, @user)
    end

    private_class_method :bind, :execute, :not_recognized
  end

end
