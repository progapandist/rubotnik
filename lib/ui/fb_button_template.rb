# rubocop:disable Metrics/MethodLength

module UI
  ########################### BUTTON TEMPLATE #############################
  # https://developers.facebook.com/docs/messenger-platform/send-api-reference/button-template
  class FBButtonTemplate < UI::BaseUiElement
    def initialize(text, buttons)
      @template = {
        recipient: {
          id: nil
        },
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: text,
              buttons: parse_buttons(buttons)
            }
          }
        }
      }
    end
  end
end
