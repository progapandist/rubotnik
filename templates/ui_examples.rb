module Commands
  # Format of hashes follows JSON format from Messenger Platform documentation:
  # https://developers.facebook.com/docs/messenger-platform/send-messages/templates
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

  def show_button_template
    button_template = UI::FBButtonTemplate.new(
      BUTTON_TEMPLATE_TEXT,
      BUTTON_TEMPLATE_BUTTONS
    )
    show(button_template)
  end

  def show_carousel(image_ratio: nil)
    if image_ratio == :square
      show(UI::FBCarousel.new(SampleElements::CAROUSEL).square_images)
    else
      show(UI::FBCarousel.new(SampleElements::CAROUSEL))
    end
  end

  def show_image
    say "Wait a bit while I pick a nice random image for you"
    img_url = 'https://unsplash.it/600/400?random'
    image = UI::ImageAttachment.new(img_url)
    show(image)
  end
end
