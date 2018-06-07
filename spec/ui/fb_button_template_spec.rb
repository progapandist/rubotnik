# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UI::FBButtonTemplate do
  let(:user) { FactoryBot.create(:user) }
  let(:text) { 'xyz' }
  let(:buttons) do
    [
      {
        type: 'web_url',
        url: 'http://google.com',
        title: 'abc'
      }
    ]
  end

  describe 'build' do
    let(:result) { described_class.new(text, buttons).build(user) }
    let(:payload) { result[:message][:attachment][:payload] }
    let(:result_buttons) { payload[:buttons] }

    it 'renders text' do
      expect(payload[:text]).to eq('xyz')
    end

    context 'with buttons' do
      it 'renders buttons correctly' do
        expect(result_buttons.length).to eq(1)
      end
    end

    context 'without buttons' do
      let(:buttons) { nil }

      it 'renders correctly' do
        expect(result_buttons.length).to eq(0)
      end
    end
  end
end
