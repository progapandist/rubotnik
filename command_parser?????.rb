class CommandParser
  def initialize(text, user, commands)
    @text = text
    @user = user
  end

  def parse
    case text
    when /coord/i, /gps/i
      @user.set_command(:show_coordinates)
      p "Command :show_coordinates is set for user #{@user.id}"
      say(@user.id, IDIOMS[:ask_location], TYPE_LOCATION)
    when /full ad/i
      @user.set_command(:show_full_address)
      p "Command :show_full_address is set for user #{@user.id}"
      say(@user.id, IDIOMS[:ask_location], TYPE_LOCATION)
    when /location/i
      @user.set_command(:lookup_location)
      p "Command :lookup_location is set for user #{@user.id}"
      say(@user.id, 'Let me know your location:', TYPE_LOCATION)
    when /carousel/i
      @user.set_command(:show_carousel)
      p "Command :show_carousel is set for user #{@user.id}"
    end
  end

end
