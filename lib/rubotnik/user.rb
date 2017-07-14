# A model for the user
class User
  attr_reader :id
  attr_accessor :answers

  def initialize(id)
    @id = id
    @commands = []
    # This hash is used for the sake of example.
    # Use your own logic to collect data.
    @answers = {}
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
end
