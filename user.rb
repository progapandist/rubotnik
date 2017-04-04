class User
  attr_reader :id
  attr_accessor :answers

  def initialize(id)
    @id = id
    @commands = []
    @answers = {}
    @greeted = false
  end

  def current_command
    @commands.last
  end

  def set_command(command)
    @commands << command
  end

  def reset_command
    @commands = []
  end

  def greet
    @greeted = true
  end

  def greeted?
    @greeted
  end

end
