# frozen_string_literal: true

module UI
  module Common
    module HasButtons
      private

      def parse_buttons(buttons)
        return [] if buttons.nil? || buttons.empty?
        buttons.map do |button|
          button[:type] = button[:type].to_s
          button
        end
      end
    end
  end
end
