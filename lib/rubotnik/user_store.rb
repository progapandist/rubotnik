require 'singleton'
require_relative 'user'
# In-memory storage for users
class UserStore
  include Singleton
  attr_reader :users
  def initialize
    @users = []
  end

  def find_or_create_user(id)
    find(id) || add(User.new(id))
  end

  # TODO: Remove debug statements

  def add(user)
    @users << user
    user = @users.last
    if user
      p "user #{user.inspect} added to store"
      p "we got #{@users.count} users: #{@users}"
    else
      p 'user not found in store yet'
    end
    user
  end

  def find(id)
    user = @users.find { |u| u.id == id }
    p "user #{user} found in store" if user
    p "we got #{@users.count} users: #{@users}" if user
    user
  end
end
