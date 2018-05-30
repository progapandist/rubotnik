# frozen_string_literal: true

require "spec_helper"

RSpec.describe UI::FBCarousel do
  let(:user) { FactoryBot.create(:user) }
  let(:text) { 'xyz' }
  let(:elements) do
    [
      {
        title: 'Random image',
        image_url: 'https://unsplash.it/760/400?random',
        subtitle: "That's a first card in a carousel",
        default_action: {
          type: 'web_url',
          url: 'https://unsplash.it'
        },
        buttons: [
          {
            type: :web_url,
            url: 'https://unsplash.it',
            title: 'Website'
          }
        ]
      }
    ]
  end

  describe 'build' do
    let(:result) { described_class.new(elements).build(user) }
    let(:payload) { result[:message][:attachment][:payload] }

    it 'renders elements correctly' do
      expect(payload[:elements].length).to eq(1)
      expect(payload[:elements].first[:buttons].first[:type]).to eq('web_url')
    end
  end
end
