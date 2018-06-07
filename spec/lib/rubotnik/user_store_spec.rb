# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rubotnik::UserStore do
  describe 'find_or_create_user' do
    let(:store) { described_class.send(:new) }
    let(:result) { store.find_or_create_user(id) }
    let(:id) { '5' }

    context 'when user exists in store' do
      let(:existing_user) { FactoryBot.create(:user, id: id) }

      before do
        store.add(existing_user)
      end

      it 'returns the user' do
        user = nil
        expect { user = result }.not_to change { store.users.length }
        expect(user).to eq(existing_user)
      end
    end

    context 'when user does not exist' do
      it 'adds user to the store' do
        user = nil
        expect { user = result }.to change { store.users.length }.by(1)
        expect(user.id).to eq(id)
      end
    end
  end
end
