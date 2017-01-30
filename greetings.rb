class Greetings
  def self.enable
    # Set call to action button when user is about to address bot
    # for the first time.
    Facebook::Messenger::Thread.set({
      setting_type: 'call_to_actions',
      thread_state: 'new_thread',
      call_to_actions: [
        {
          payload: 'START'
        }
      ]
    }, access_token: ENV['ACCESS_TOKEN'])

    # Set greeting (for first contact)
    Facebook::Messenger::Thread.set({
      setting_type: 'greeting',
      greeting: {
        text: 'Coordinator welcomes you!'
      },
    }, access_token: ENV['ACCESS_TOKEN'])
  end
end
