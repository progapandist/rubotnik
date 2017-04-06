require_relative 'user'
require_relative 'user_store'
require_relative 'commands'
include Commands

class Rubotnik
  def self.route(incoming, &block)
    p incoming
    p incoming.class
    @user = UserStore.instance.find_or_create_user(incoming.sender['id'])
    dispatch(&block)
    @message = incoming if incoming.class == Facebook::Messenger::Incoming::Message
    @postback = incoming if incoming.class == Facebook::Messenger::Incoming::Postback
  end

  private_class_method def self.dispatch(&block)
    if @user.current_command
      command = @user.current_command
      # NB: commands should exist under the same namespace as Rubotnik in order to call them
      execute(command)
      puts "Command #{command} is executed for user #{@user.id}" # log
    else
      puts "User #{@user.id} does not have a command assigned yet" # log
      bind_commands(&block)
    end
  end

  private_class_method def self.bind_commands(&block)
    @matched = false
    class_eval(&block)
  end

  # We only greet user once for the whole interaction
  private_class_method def self.greet(text = "Hello")
    unless @user.greeted?
      if block_given?
        yield
      else
        say text
      end
      @user.greet
    end
  end

  private_class_method def self.bind(regex_string, to: nil, start_thread: {}, check_payload: '')
    proceed = (!@postback.nil? && @postback.payload == regex_string.upcase) ||
              (!@message.nil? && @message.text =~ /#{regex_string}/i)

    if check_payload.class == String && !check_payload.empty?
      proceed = proceed && (@message.quick_reply == check_payload.upcase)
    end

    if proceed
      @matched = true
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

  private_class_method def self.unrecognized
    unless @matched
      puts "unrecognized triggered" # debug
      yield
      @user.reset_command
    end
  end

  private_class_method def self.execute(command)
    method(command).call
  end
end
