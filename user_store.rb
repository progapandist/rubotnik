require 'singleton'
require_relative 'user'

class UserStore
  include Singleton
  attr_reader :users
  def initialize
    @users = []
  end

  def find_or_create_user(id)
    self.find(id) || self.add(User.new(id))
  end

  def add(user)
    @users << user
    @users.last
  end

  def find(id)
    @users.find { |u| u.id == id }
  end
end
