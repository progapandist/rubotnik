# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rubotnik::Helpers do
  class DummyClass
    include Rubotnik::Helpers

    def initialize(user:, message:)
      @user = user
      @message = message
    end
  end

  let(:user) { FactoryBot.create(:user) }
  let(:message) { FactoryBot.create(:message) }
  let(:instance) { DummyClass.new(user: user, message: message) }

  describe 'say' do
    let(:call) do
      instance.send(:say, 'text')
    end

    before do
      allow(Bot).to receive(:deliver)
    end

    it 'builds correct payload' do
      expect(Bot).to receive(:deliver) do |result|
        expect(result[:recipient][:id]).to eq(user.id)
        expect(result[:message][:text]).to eq('text')
      end

      call
    end

    context 'when quick replies passed' do
      let(:call) do
        instance.send(:say, 'text', quick_replies: ['ok'])
      end

      it 'adds them to the payload' do
        expect(Bot).to receive(:deliver) do |result|
          quick_replies = result[:message][:quick_replies]
          expect(quick_replies.length).to eq(1)
          expect(quick_replies.first[:title]).to eq('ok')
        end

        call
      end
    end
  end

  describe 'show' do
    let(:ui_element) do
      UI::ImageAttachment.new('xxx')
    end

    it 'sends ui element\'s payload' do
      expect(Bot).to receive(:deliver) do |payload|
        expect(payload[:recipient][:id]).to eq(user.id)
      end

      instance.send(:show, ui_element)
    end
  end

  describe 'next_command' do
    it 'sets next command' do
      expect { instance.send(:next_command, :cmd) }.to change { user.current_command }.to(:cmd)
    end
  end

  describe 'stop_thread' do
    before do
      user.assign_command(:cmd)
    end

    it 'clears user\' commands' do
      expect { instance.send(:stop_thread) }.to change { user.current_command }.to(nil)
    end
  end

  describe 'text_message?' do
    context 'when current message has Message type' do
      it 'returns true' do
        expect(instance.send(:text_message?)).to eq(true)
      end
    end

    context 'when current message has Postback type' do
      let(:message) { FactoryBot.create(:postback) }

      it 'returns false' do
        expect(instance.send(:text_message?)).to eq(false)
      end
    end
  end

  describe 'message_contains_location?' do
    context 'when current message has location' do
      let(:message) { FactoryBot.create(:message, :with_location) }

      it 'returns true' do
        expect(instance.send(:message_contains_location?)).to eq(true)
      end
    end

    context 'when current message has no location' do
      it 'returns false' do
        expect(instance.send(:message_contains_location?)).to eq(false)
      end
    end
  end

  describe 'get_user_info' do
    let(:response) do
      instance_double(HTTParty::Response, code: 200, body: body)
    end
    let(:body) do
      {
        email: 'xxx@yyy.com',
        last_name: 'Bajena'
      }.to_s
    end

    before do
      allow(ENV).to receive(:[]).and_wrap_original do |m, *args|
        if args[0] == 'ACCESS_TOKEN'
          'token'
        else
          m.call(*args)
        end
      end

      allow(message).to receive(:typing_on)
      allow(message).to receive(:typing_off)
    end

    it 'calls graph api with correct url' do
      expected_url = "https://graph.facebook.com/v2.8"\
                      "/#{user.id}?fields=email,last_name&access_token=token"
      expect(HTTParty)
        .to receive(:get).with(expected_url).and_return(response)

      instance.send(:get_user_info, :email, :last_name)
    end
  end
end
