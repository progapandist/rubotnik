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
  let(:payload) { result[:message][:attachment][:payload] }

  describe 'build' do
    let(:result) { described_class.new(elements).build(user) }

    it 'renders elements correctly' do
      expect(payload[:elements].length).to eq(1)
      expect(payload[:elements].first[:buttons].first[:type]).to eq('web_url')
    end
  end

  describe 'square images' do
    let(:result) { described_class.new(elements).square_images.build(user) }

    it 'sets aspect ratio to square and returns self' do
      expect(payload[:image_aspect_ratio]).to eq('square')
    end
  end

  describe 'horizontal images' do
    let(:result) { described_class.new(elements).horizontal_images.build(user) }

    it 'sets aspect ratio to horizontal and returns self' do
      expect(payload[:image_aspect_ratio]).to eq('horizontal')
    end
  end
end
