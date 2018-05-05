require "spec_helper"

RSpec.describe Rubotnik::MessageDispatch do
  let(:sender_id) { 2 }
  let(:message) do
    FactoryBot.build(:message, sender_id: sender_id, text: message_text)
  end
  let(:message_text) { "bla" }
  let(:user) do
    FactoryBot.build(:user, :with_commands, id: sender_id, commands: commands)
  end
  let(:commands) { [] }
  let(:dispatch) { described_class.new(message) }
  let(:commands_module) do
    Module.new do
      def command1
      end

      def command2
      end
    end
  end

  before do
    allow(UserStore.instance).to receive(:find_or_create_user).
      with(sender_id) { user }
    dispatch.extend(commands_module)
  end

  describe "route" do
    context "when user has an active command" do
      let(:commands) { [:command1, :command2] }

      it "executes the command" do
        expect(dispatch).to receive(:command2)

        dispatch.route
      end

      context "when a command raises an error" do
        let(:debug) { nil }
        let(:commands_module) do
          Module.new do
            def command2
              raise "err"
            end
          end
        end

        before do
          allow(ENV).to receive(:[]).and_wrap_original do |m, *args|
            if args[0] == "DEBUG"
              debug
            else
              m.call(*args)
            end
          end
        end

        context "and debug is on" do
          let(:debug) { "true" }

          it "shows the error" do
            expect(dispatch).to receive(:say) { "There was an error: err" }

            dispatch.route
          end
        end

        context "and debug is off" do
          it "reraises the error" do
            expect(dispatch).to receive(:command2).and_call_original

            expect { dispatch.route }.to raise_error("err")
          end
        end
      end
    end

    context "with user has no active command" do
      context "and message matches a binding with 'all: true'" do
        let(:message_text) { "good morning" }

        context "when :to option is given" do
          it "executes the command" do
            expect(dispatch).to receive(:command2)

            dispatch.route do
              bind "Good", "morning", all: true, to: :command2
            end
          end
        end

        context "when block is given" do
          it "executes the command" do
            expect(dispatch).to receive(:command1)

            dispatch.route do
              bind "Good", "morning", all: true do
                command1
              end
            end
          end
        end
      end

      context "and message matches a binding without 'all: true'" do
        let(:message_text) { "Morning, sir" }

        context "when :to option is given" do
          it "executes the command" do
            expect(dispatch).to receive(:command2)

            dispatch.route do
              bind "Good", "morning", to: :command2
            end
          end
        end

        context "when block is given" do
          it "executes the command" do
            expect(dispatch).to receive(:command1)

            dispatch.route do
              bind "Good", "morning" do
                command1
              end
            end
          end
        end
      end

      context "and message matches multiple commands" do
        let(:message_text) { "do something" }

        it "executes only the first matched command" do
          expect(dispatch).to receive(:command1)
          expect(dispatch).not_to receive(:command2)

          dispatch.route do
            bind "do", "something", all: true do
              command1
            end

            bind "something" do
              command2
            end
          end
        end
      end

      context "and message matches no binding" do
        it "executes 'default' block" do
          expect(dispatch).to receive(:command1)

          dispatch.route do
            bind "something" do
              command2
            end

            default do
              command1
            end
          end
        end
      end
    end
  end
end
