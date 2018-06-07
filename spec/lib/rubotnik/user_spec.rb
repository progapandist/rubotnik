# frozen_string_literal: true

require 'spec_helper'

RSpec.describe User do
  let(:user) { described_class.new(123) }

  describe 'command manipulation' do
    it 'allows command manipulation' do
      expect(user.current_command).to eq(nil)
      user.assign_command(:command)
      expect(user.current_command).to eq(:command)
      user.reset_command
      expect(user.current_command).to eq(nil)
    end
  end

  describe 'session' do
    it 'has a session object for storing data' do
      expect(user.session).to eq({})
    end
  end
end
