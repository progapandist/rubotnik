# rubocop:disable Metrics/MethodLength
module UI
  # https://developers.facebook.com/docs/messenger-platform/send-api-reference/image-attachment
  class ImageAttachment < UI::BaseUiElement
    def initialize(url)
      @template = {
        recipient: {
          id: nil
        },
        message: {
          attachment: {
            type: 'image',
            payload: {
              url: url
            }
          }
        }
      }
    end
  end
end
