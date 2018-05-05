# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength

module UI
  class BaseUiElement
    # Sends the valid JSON to Messenger API
    def send(user)
      formed = build(user)
      Bot.deliver(formed, access_token: ENV['ACCESS_TOKEN'])
    end

    # Use this method to return a valid hash and save it for later
    def build(user)
      @template[:recipient][:id] = user.id
      @template
    end
  end
end
