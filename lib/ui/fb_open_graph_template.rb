# rubocop:disable Metrics/MethodLength

module UI
  ########################### OPEN GRAPH TEMPLATE #############################
  # https://developers.facebook.com/docs/messenger-platform/send-messages/template/open-graph
  class FBOpenGraphTemplate < UI::BaseUiElement
    include UI::Common::HasButtons

    def initialize(url, buttons = [])
      @url = url
      @buttons = buttons

      @template = {
        recipient: {
          id: nil
        },
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'open_graph',
              elements: elements
            }
          }
        }
      }
    end

    private

    attr_reader :url, :buttons

    def elements
      res = { url: url }

      buttons_payload = parse_buttons(buttons)
      res[:buttons] = buttons_payload if buttons_payload.any?

      [res]
    end
  end
end
