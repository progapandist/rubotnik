module Rubotnik

  # TODO: Change name 
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
        # NOTE: You can user {{user_last_name}} or {{user_full_name}} to
        # personalize greeting.
        greeting: {
          text: "Hello {{user_first_name}}"
        },
      }, access_token: ENV['ACCESS_TOKEN'])
    end
  end
end

# base_uri "https://graph.facebook.com/v2.6/me/messenger_profile?access_token="
#
# post(ENV["ACCESS_TOKEN"], { get_started: { payload: "TEST" } })
