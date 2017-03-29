class MessageDispatcher
  def initialize(user, message)
    @user = user
    @message = message
  end

  def dispatch
    greet_user(@user) unless @user.greeted?

    if @user.current_command
      command = @user.current_command
      method(command).call(@message, @user)
      puts "Command #{command} is executed for user #{@user.id}"
      @user.reset_command # should we reset command inside a command object?
      @user.disengage
    else
      puts "User #{@user.id} does not have a command assigned yet"
      parse_commands
    end
  end

  private

  def parse_commands
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
      @user.disengage
    when /questionnaire/i
      @user.set_command(:start_questionnaire)
      say(@user, "Welcome to the sample questionnaire! Are you ready?")
    else
      show_replies_menu(@user, MENU_REPLIES)
    end
  end
end
