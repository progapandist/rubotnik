# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rubotnik::PostbackDispatch do
  let(:sender_id) { 2 }
  let(:postback) do
    FactoryBot.build(:postback, sender_id: sender_id, payload: payload)
  end
  let(:payload) { 'START' }
  let(:user) do
    FactoryBot.build(:user, :with_commands, id: sender_id, commands: commands)
  end
  let(:commands) { [] }
  let(:dispatch) { described_class.new(postback) }
  let(:commands_module) do
    Module.new do
      def command1; end

      def command2; end
    end
  end

  before do
    allow(UserStore.instance)
      .to receive(:find_or_create_user)
        .with(sender_id) { user }
    dispatch.extend(commands_module)
  end

  describe 'route' do
    context 'when an existing postback is matched' do
      context 'when block is given' do
        let(:call) do
          dispatch.route do
            bind 'START' do
              command1
            end
          end
        end

        it 'executes the command' do
          expect(dispatch).to receive(:command1)

          call
        end
      end

      context 'when :to option is given' do
        let(:call) do
          dispatch.route do
            bind 'START', to: :command2
          end
        end

        it 'clears user\'s commands and session' do
          user.session[:key] = 'test'
          expect(user).to receive(:reset_command).and_call_original

          expect { call }.to change { user.session }.to({})
        end

        it 'executes the matched command' do
          expect(dispatch).to receive(:command2)

          call
        end

        context 'and reply_with is given' do
          let(:quick_replies) do
            [['Good!', 'OK'], ['Not so well', 'NOT_OK']]
          end
          let(:call) do
            qr = quick_replies
            dispatch.route do
              bind 'START', to: :command2, reply_with: {
                message: 'abc',
                quick_replies: qr
              }
            end
          end

          before do
            allow(dispatch).to receive(:say)
          end

          it 'says given text' do
            expect(dispatch).to receive(:say).with(
              'abc', quick_replies: quick_replies
            )

            call
          end

          it 'sets a next command to execute' do
            expect { call }.to change { user.current_command }.to(:command2)
          end
        end
      end
    end
  end
end
