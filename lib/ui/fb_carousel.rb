# rubocop:disable Metrics/MethodLength
module UI
  ################## GENERIC TEMPLATE (aka CAROUSEL) #######################
  # https://developers.facebook.com/docs/messenger-platform/send-api-reference/generic-template
  class FBCarousel < UI::BaseUiElement
    include Common::HasButtons

    def initialize(elements)
      @template = {
        recipient: { id: nil },
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'generic',
              image_aspect_ratio: 'horizontal',
              elements: parse_elements(elements)
            }
          }
        }
      }
    end

    # set image aspect ratio to 'square'
    def square_images
      self.image_aspect_ratio = 'square'
      self
    end

    # set image aspect ratio to 'horizontal'
    def horizontal_images
      self.image_aspect_ratio = 'horizontal'
      self
    end

    private

    def image_aspect_ratio=(type)
      @template[:message][:attachment][:payload][:image_aspect_ratio] = type
    end

    def parse_elements(elements)
      elements = [elements] if elements.class == Hash
      elements.map do |elt|
        elt[:buttons] = parse_buttons(elt[:buttons])
        elt
      end
    end
  end
end
