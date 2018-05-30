# frozen_string_literal: true

require "spec_helper"

RSpec.describe UI::ImageAttachment do
  let(:user) { FactoryBot.create(:user) }
  let(:url) { 'https://unsplash.it/760/400?random' }

  describe 'build' do
    let(:result) { described_class.new(url).build(user) }
    let(:payload) { result[:message][:attachment][:payload] }

    it 'renders elements correctly' do
      expect(payload[:url]).to eq(url)
    end
  end
end
