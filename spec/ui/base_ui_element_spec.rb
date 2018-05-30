# frozen_string_literal: true

require "spec_helper"

RSpec.describe UI::BaseUiElement do
  class DummyElement < described_class
    def initialize
      @template = {
        recipient: {
          id: nil
        }
      }
    end
  end

  let(:user) { FactoryBot.create(:user) }

  describe 'build' do
    let(:result) { DummyElement.new.build(user) }
    let(:recipient_id) { result[:recipient][:id] }

    it 'sets correct user id' do
      expect(recipient_id).to eq(user.id)
    end
  end
end
