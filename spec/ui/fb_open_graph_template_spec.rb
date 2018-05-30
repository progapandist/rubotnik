# frozen_string_literal: true

require "spec_helper"

RSpec.describe UI::FBOpenGraphTemplate do
  let(:url) { 'https://github.com/progapandist/rubotnik' }
  let(:user) { FactoryBot.create(:user) }

  describe 'build' do
    let(:result) { described_class.new(url).build(user) }
    let(:elements) { result[:message][:attachment][:payload][:elements].first }

    context 'when buttons not passed' do
      it 'renders correctly' do
        expect(elements).to eq(url: url)
      end
    end

    context 'when buttons passed' do
      let(:buttons) do
        [
          {
            type: 'web_url',
            url: url,
            title: 'abc'
          }
        ]
      end
      let(:result) { described_class.new(url, buttons).build(user) }

      it 'adds buttons to template' do
        expect(elements[:buttons].first[:type]).to eq('web_url')
        expect(elements[:buttons].first[:title]).to eq('abc')
        expect(elements[:buttons].first[:url]).to eq(url)
      end
    end
  end
end
