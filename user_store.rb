require 'singleton'

class UserStore
  include Singleton
  attr_reader :users
  def initialize
    @users = []
  end

  def add(user)
    @users << user
    @users.last
  end

  def find(id)
    @users.find { |u| u.id == id }
  end
end
