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
    p @message # log incoming message details
    case @message.text
    when /coord/i, /gps/i
      @user.set_command(:show_coordinates)
      p "Command :show_coordinates is set for user #{@user.id}"
      say(@user, IDIOMS[:ask_location], TYPE_LOCATION)
    when /full ad/i
      @user.set_command(:show_full_address)
      p "Command :show_full_address is set for user #{@user.id}"
      say(@user, IDIOMS[:ask_location], TYPE_LOCATION)
    when /location/i
      @user.set_command(:lookup_location)
      p "Command :lookup_location is set for user #{@user.id}"
      say(@user, 'Let me know your location:', TYPE_LOCATION)
    when /carousel/i
      show_carousel(@user.id)
      @user.reset_command
    when /button template/i
      show_button_template(@user.id)
      @user.reset_command
    when /questionnaire/i
      @user.set_command(:start_questionnaire)
      replies = UI::QuickReplies.new(["Yes", "START_QUESTIONNAIRE"],
                                             ["No", "STOP_QUESTIONNAIRE"]).build
      say(@user, "Welcome to the sample questionnaire! Are you ready?", replies)
    else
      # Show a set of options if command is not understood
      show_replies_menu(@user, MENU_REPLIES)
    end
  end
end
