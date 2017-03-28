require 'json'

# Also known as 'generic template'
# https://developers.facebook.com/docs/messenger-platform/send-api-reference/generic-template

# Examples for all basic UI elements and content types 

module UIElements

  # TODO: Account for square images

  class FBCarousel
    def initialize(opts = {})
      @template = {
        # TODO: Do we need to provide an id at init?
        recipient: { id: nil},
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'generic',
              elements: parse_elements(opts) || nil # redundant?
            }
          }
        }
      }
    end

    # TODO: Do we need two separate methods for build and send?
    def send(id)
      template = build(id)
      Bot.deliver(template, access_token: ENV['ACCESS_TOKEN'])
    end

    def build(id)
      @template[:recipient][:id] = id
      @template
    end


    # MAKE METHODS BELOW PRIVATE AFTER TESTING

    # [{title: String, image_url: String, subtitle: String, default_url: String, buttons: []}]
    def parse_elements(elements)
      elements = [elements] if elements.class == Hash
      elements.map do |elt|
        # TODO: custom error?
        raise ArgumentError, "Title is a required field" unless elt.key?(:title)
        elt[:buttons] = parse_buttons(elt[:buttons])
        # TODO: default_url doesn't work correctly for now
        unless elt[:default_url].nil?
          elt[:default_action] = {
            type: "web_url",
            url: elt[:default_url],
            messenger_extensions: false,
            webview_height_ratio: "tall",
            fallback_url: elt[:default_url]
          }
          elt.delete(:default_url)
        end
        elt
      end
    end

    # TODO: Extract button functionality to Button class?
    # Account for all button types from API or remove type check altogether!

    # [{type: :web_url, url: String, title: String}]
    # [{type: :postback, title: String, payload: String}]
    def parse_buttons(buttons)
      return [] if buttons.nil? || buttons.empty?
      buttons.map do |button|
        # TODO: change for custom error type?
        unless [:web_url, :postback].include?(button[:type].to_sym)
          raise ArgumentError, "Unsupported button type"
        end
        button[:type] = button[:type].to_s
        button
      end
    end
  end
end
