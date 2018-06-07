# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength

module UI
  class BaseUiElement
    # Use this method to return a valid hash and save it for later
    def build(user)
      @template[:recipient][:id] = user.id
      @template
    end
  end
end
