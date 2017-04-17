module SampleElements
  CAROUSEL = [
    {
      title: 'Random image',
      # Horizontal image should have 1.91:1 ratio
      image_url: 'https://unsplash.it/760/400?random',
      subtitle: "That's a first card in a carousel",
      default_action: {
        type: 'web_url',
        url: 'https://unsplash.it'
      },
      buttons: [
        {
          type: :web_url,
          url: 'https://unsplash.it',
          title: 'Website'
        },
        {
          type: :postback,
          title: 'Square Images',
          payload: 'SQUARE_IMAGES'
        }
      ]
    },
    {
      title: 'Another random image',
      # Horizontal image should have 1.91:1 ratio
      image_url: 'https://unsplash.it/600/315?random',
      subtitle: "And here's a second card. You can add up to 10!",
      default_action: {
        type: 'web_url',
        url: 'https://unsplash.it'
      },
      buttons: [
        {
          type: :web_url,
          url: 'https://unsplash.it',
          title: 'Website'
        },
        {
          type: :postback,
          title: 'Unsquare Images',
          payload: 'HORIZONTAL_IMAGES'
        }
      ]
    }
  ].freeze

  BUTTON_TEMPLATE_TEXT = "Look, I'm a message and I have " \
                         'some buttons attached!'.freeze
  BUTTON_TEMPLATE_BUTTONS = [
    {
      type: :web_url,
      url: 'https://medium.com/@progapanda',
      title: "Andy's Medium"
    },
    {
      type: :postback,
      payload: 'BUTTON_TEMPLATE_ACTION',
      title: 'Useful Button'
    }
  ].freeze
end
