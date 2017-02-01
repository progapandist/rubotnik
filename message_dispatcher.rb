require_relative "commands"

#TODO: HANDLE UNKNOWN COMMAND

class MessageDispatcher
  include Facebook::Messenger
  include Commands

  def initialize(user, message)
    @user = user
    @message = message
  end

  def dispatch
    show_replies_menu(@user.id, MENU_REPLIES) unless @user.engaged?
    @user.engage
    if @user.next_command
      next_command = @user.next_command
      method(next_command).call(@message, @user.id)
      puts "Command #{command} is executed for user #{@user.id}"
      @user.reset_command
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
      @user.set_next_command(:show_coordinates)
      p "Command :show_coordinates is set for user #{@user.id}"
      say(@user.id, IDIOMS[:ask_location], TYPE_LOCATION)
    when /full ad/i
      @user.set_next_command(:show_full_address)
      p "Command :show_full_address is set for user #{@user.id}"
      say(@user.id, IDIOMS[:ask_location], TYPE_LOCATION)
    when /location/i
      @user.set_next_command(:lookup_location)
      p "Command :lookup_location is set for user #{@user.id}"
      say(@user.id, 'Let me know your location:', TYPE_LOCATION)
    when /carousel/i
      show_carousel(@user.id)
      @user.disengage
    end
  end
end
