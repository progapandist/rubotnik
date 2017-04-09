module SampleElements
  CAROUSEL = [
              {
                title: "Nicolas",
                # Horizontal image should have 1.91:1 ratio
                image_url: "https://www.placecage.com/760/400",
                subtitle: "That's a first card in a carousel",
                buttons: [
                  { type: :web_url,
                    url: "https://www.placecage.com",
                    title: "More Nicolas" },
                    { type: :postback,
                      title: "Square Images",
                      payload: "SQUARE_IMAGES"
                    }
                  ]
                },
                {
                  title: "Steven",
                  # Horizontal image should have 1.91:1 ratio
                  image_url: "https://www.stevensegallery.com/760/400",
                  subtitle: "And here's a second card. You can add up to 10!",
                  buttons: [
                    {
                      type: :web_url,
                      url: "https://www.stevensegallery.com/",
                      title: "More Steven"
                    },
                    { type: :postback,
                      title: "Unsquare Images",
                      payload: "HORIZONTAL_IMAGES"
                    }
                  ]
                }
              ]

BUTTON_TEMPLATE_TEXT = "Look, I'm a message and I have some buttons attached!"
BUTTON_TEMPLATE_BUTTONS = [
  { type: :web_url, url: "https://medium.com/@progapanda", title: "Andy's Medium" },
  { type: :postback, payload: "BUTTON_TEMPLATE_ACTION", title: "Useful Button"}
]

end
