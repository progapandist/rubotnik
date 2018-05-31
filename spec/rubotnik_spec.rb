require 'spec_helper'

RSpec.describe Rubotnik do
  it 'has a version number' do
    expect(Rubotnik::VERSION).not_to be nil
  end

  describe 'subscribe' do
    it 'subscribes to a fb page' do
      token = 'xxx'
      expect(Facebook::Messenger::Subscriptions)
        .to receive(:subscribe).with(access_token: token)

      described_class.subscribe(token)
    end
  end

  describe 'route' do
    let(:hook) { proc { |args| args } }

    context 'when the event is not handled yet' do
      it 'passes the handling to Bot' do
        described_class.route(:read, &hook)

        expect(Bot.trigger(:read, 'xxx')).to eq('xxx')
      end
    end

    context 'when the event is a "message"' do
      let(:message) { FactoryBot.create(:message) }
      let(:dispatch) { instance_double(Rubotnik::MessageDispatch) }

      it 'calls correct dispatch class' do
        expect(Rubotnik::MessageDispatch)
          .to receive(:new).with(message).and_return(dispatch)
        expect(dispatch).to receive(:route).and_yield(hook)

        described_class.route(:message, &hook)

        Bot.trigger(:message, message)
      end
    end

    context 'when the event is a "postback"' do
      let(:postback) { FactoryBot.create(:postback) }
      let(:dispatch) { instance_double(Rubotnik::PostbackDispatch) }

      it 'calls correct dispatch class' do
        expect(Rubotnik::PostbackDispatch)
          .to receive(:new).with(postback).and_return(dispatch)
        expect(dispatch).to receive(:route).and_yield(hook)

        described_class.route(:postback, &hook)

        Bot.trigger(:postback, postback)
      end
    end
  end

  describe 'set_profile' do
    let(:profile) do
      {
        get_started: {
          payload: 'START'
        }
      }
    end

    it 'sets requested profiles' do
      expect(Facebook::Messenger::Profile)
        .to receive(:set).with(profile, anything)

      described_class.set_profile(profile)
    end
  end
end
