# rubocop:disable all
module Rubotnik
  # Enables persistent menu for your bot
  class PersistentMenu
    def self.enable
      # Design your persistent menu here:
      Facebook::Messenger::Profile.set({
        persistent_menu: [
          {
            locale: 'default',
            # If this option is set to true,
            # user will only be able to interact with bot
            # through the persistent menu
            # (composing a message will be disabled)
            composer_input_disabled: false,
            call_to_actions: [
              {
                type: 'nested',
                title: 'Sample UI elements',
                call_to_actions: [
                  {
                    title: 'Generic Template',
                    type: 'postback',
                    payload: 'CAROUSEL'
                  },
                  {
                    title: 'Button Template',
                    type: 'postback',
                    payload: 'BUTTON_TEMPLATE'
                  },
                  {
                    title: 'Image Attachment',
                    type: 'postback',
                    payload: 'IMAGE_ATTACHMENT'
                  }
                ]
              },
              {
                type: 'postback',
                title: 'Location lookup',
                payload: 'LOCATION'
              },
              {
                type: 'postback',
                title: 'Sample questionnaire',
                payload: 'QUESTIONNAIRE'
              }
            ]
          }
        ]
        }, access_token: ENV['ACCESS_TOKEN'])
    end
  end
end
