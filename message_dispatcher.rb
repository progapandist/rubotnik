require_relative "user"
require_relative "commands"

class MessageDispatcher
  include Facebook::Messenger
  include Commands
  def initialize(user, message)
    @user = user
    @message = message
  end

  def dispatch
    show_replies_menu(@user.id, MENU_REPLIES) unless @user.engaged?
    if @user.command
      command = @user.command
      method(command).call(@message, @user.id)
      p "Command #{command} is taken care of"
      @user.reset_command
      @user.disengage
    else
      p "User doesn't have any command assigned yet"
      @user.engage
      case @message.text
      when /coord/i, /gps/i
        @user.set_command(:show_coordinates)
        p "Command :show_coordinates is set"
        say(@user.id, IDIOMS[:ask_location], TYPE_LOCATION)
      when /full ad/i
        @user.set_command(:show_full_address)
        p "Command :show_full_address is set"
        say(@user.id, IDIOMS[:ask_location], TYPE_LOCATION)
      when /location/i
        @user.set_command(:lookup_location)
        p "Command :lookup_location is set"
        say(@user.id, 'Let me know your location:', TYPE_LOCATION)
      end
    end
  end
end
