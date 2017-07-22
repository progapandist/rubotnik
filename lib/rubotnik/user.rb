# TODO: .send method that takes UI classes to do smth like @user.send(UI::ImageAttachment)

# A model for the user
class User
  attr_reader :id
  attr_accessor :session

  def initialize(id)
    @id = id
    @commands = []
    @session = {}
  end

  def current_command
    @commands.last
  end

  def assign_command(command)
    @commands << command
  end

  def reset_command
    @commands = []
  end

  def send(payload)
    # TODO Probably have to require and include facebook/messenger here
  end
end
