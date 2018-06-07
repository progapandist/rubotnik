class Rubotnik::User
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
end
