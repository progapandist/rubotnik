#Parser.bind_commands(@message, @user) do
#  bind /carousel/i to: :show_carousel
#  bind /location/i to: :lookup_location, start_thread: {message: "Message", quick_replies: [{}]}
#end

# ATTEMPT AT DSL 
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
      @matched ||= true
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
      puts "not_recognized triggered"
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

class MessageDispatcher
  def initialize(user, message)
    @user = user
    @message = message
  end

  def dispatch
    # We only greet user once for the whole interaction
    greet_user(@user) unless @user.greeted?

    # The main switch happens here:
    # user either has a threaded command set from previous interaction
    # or we go back to top level commands
    if @user.current_command
      command = @user.current_command
      method(command).call(@message, @user)
      puts "Command #{command} is executed for user #{@user.id}" # log
    else
      puts "User #{@user.id} does not have a command assigned yet" # log
      parse_commands
    end
  end

  private


  # PARSE INCOMING MESSAGES HERE (TOP LEVEL ONLY) AND ASSIGN COMMANDS
  # FROM THE COMMANDS MODULE

  def parse_commands

    # TESTING THE DSL ON SOME COMMANDS
    # NB: Will match multiple triggers in one phrase
    # TODO: Provide multiple regexps for the same binding
    Parser.bind_commands(@message, @user) do
      # Any string will be turned into case-insensitive regex pattern
      # You can provide regex directly

      # Use with 'to:' syntax to bind to a command found in Commands
      bind "carousel", to: :show_carousel

      # Use with block if you want to provide response behaviour
      # directly without looking for command in Commands
      bind "screw" do
        say(@user, "Screw yourself!")
      end

      # Use with 'to:' and 'start_thread:' to point to the first command in a thread
      # Provide message asking input for the next command in the nested hash
      # You can also pass build and pass an array of quick replies
      bind "location", to: :lookup_location,
                       start_thread: {
                         message: "Le me know your location",
                         quick_replies: TYPE_LOCATION
                       }

      # Falback action if none of the commands matched the input,
      # NB: Should always come last. Takes a block.
      not_recognized do
        show_replies_menu(@user, MENU_REPLIES)
      end

    end

    p @message # log incoming message details
    # case @message.text
    # when /coord/i, /gps/i
    #   @user.set_command(:show_coordinates)
    #   p "Command :show_coordinates is set for user #{@user.id}"
    #   say(@user, IDIOMS[:ask_location], TYPE_LOCATION)
    # when /full ad/i
    #   @user.set_command(:show_full_address)
    #   p "Command :show_full_address is set for user #{@user.id}"
    #   say(@user, IDIOMS[:ask_location], TYPE_LOCATION)
    # # when /location/i
    # #   @user.set_command(:lookup_location)
    # #   p "Command :lookup_location is set for user #{@user.id}"
    # #   say(@user, 'Let me know your location:', TYPE_LOCATION)
    # # when /carousel/i
    # #   show_carousel(@message, @user)
    # #   @user.reset_command
    # when /button template/i
    #   show_button_template(@user.id)
    #   @user.reset_command
    # when /questionnaire/i
    #   @user.set_command(:start_questionnaire)
    #   replies = UI::QuickReplies.new(["Yes", "START_QUESTIONNAIRE"],
    #                                          ["No", "STOP_QUESTIONNAIRE"]).build
    #   say(@user, "Welcome to the sample questionnaire! Are you ready?", replies)
    # else
    #   # Show a set of options if command is not understood
    #   show_replies_menu(@user, MENU_REPLIES)
    # end
  end
end
