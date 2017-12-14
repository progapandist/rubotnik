module Profile
  # Configure profile for your bot (Start Button, Greeting, Menu)

  START_BUTTON = {
    get_started: {
      payload: 'START'
    }
  }

  START_GREETING = {
    greeting: [
      {
        locale: 'default',
        text: "Hello and welcome, {{user_first_name}}! Say 'hi!'"
      }
    ]
  }

  SIMPLE_MENU = {
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
            title: 'Nested Item',
            call_to_actions: [
              {
                title: 'Sub Item 1',
                type: 'postback',
                payload: 'SUB_ITEM_1' # this postback has to be implemented in your main.rb
              },
              {
                title: 'Sub Item 2',
                type: 'postback',
                payload: 'SUB_ITEM_2'
              }
            ]
          },
          {
            type: 'postback',
            title: 'Root Item',
            payload: 'ROOT_ITEM'
          }
        ]
      }
    ]
  }
end
