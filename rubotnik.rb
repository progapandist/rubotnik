class Rubotnik
  # TODO: Find better name than 'dispatch'
  def self.dispatch(message, &block)
    p message.class # logging
    p message # logging
    # create or find user on first connect
    sender_id = message.sender['id']
    # TODO: Refactor as find_or_add_user
    user = UserStore.instance.find(sender_id) || UserStore.instance.add(User.new(sender_id))
    MessageDispatcher.dispatch(user, message)
    Parser.bind_commands(message, user, &block)
  end
end
