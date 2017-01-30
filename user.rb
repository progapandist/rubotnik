class User
  attr_reader :id, :commands
  def initialize(id)
    @id = id
    @commands = []
  end

  def command
    @commands.last
  end

  def set_command(command)
    @commands << command
  end

  def reset_command
    @commands = []
  end
end
