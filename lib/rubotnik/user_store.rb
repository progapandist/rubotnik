require 'singleton'
require_relative 'user'
# In-memory storage for users
class Rubotnik::UserStore
  include Singleton
  attr_reader :users

  def initialize
    @users = []
  end

  def find_or_create_user(id)
    find(id) || add(Rubotnik::User.new(id))
  end

  def add(user)
    @users << user
    user = @users.last
    if user
      Rubotnik.logger.info "user #{user.inspect} added to store"
      Rubotnik.logger.info "we got #{@users.count} users: #{@users}"
    else
      Rubotnik.logger.info 'user not found in store yet'
    end
    user
  end

  def find(id)
    user = @users.find { |u| u.id == id }
    Rubotnik.logger.info "user #{user} found in store" if user
    Rubotnik.logger.info "we got #{@users.count} users: #{@users}" if user
    user
  end
end
