# frozen_string_literal: true

require "spec_helper"

RSpec.describe UI::QuickReplies do
  let(:user) { FactoryBot.create(:user) }
  let(:url) { 'https://unsplash.it/760/400?random' }

  describe 'location' do
    it 'renders correctly' do
      expect(described_class.location).to eq(
        [{ content_type: 'location' }]
      )
    end
  end

  describe 'build' do
    let(:result) do
      described_class.build(*arguments)
    end

    context 'when Hash passed' do
      let(:arguments) { [argument] }

      context 'when content_type is provided' do
        let(:argument) do
          {
            payload: 'xxx',
            content_type: 'text'
          }
        end

        it 'renders correctly' do
          expect(result).to eq([argument])
        end
      end

      context 'when content_type is not provided' do
        let(:argument) do
          {
            payload: 'xxx'
          }
        end

        it 'renders correctly' do
          expect(result).to eq([{ payload: 'xxx', content_type: 'text' }])
        end

        context 'when there is no payload provided' do
          let(:argument) do
            {
              text: 'xxx'
            }
          end

          it 'raises ArgumentError' do
            expect { result }.to raise_error(ArgumentError)
          end
        end
      end
    end

    context 'when Array passed' do
      let(:arguments) do
        [
          ['Good!', 'OK'],
          ['Not so well', 'NOT_OK']
        ]
      end

      context 'when array of wrong format passed' do
        let(:arguments) do
          [[1,2,3]]
        end

        it 'raises ArgumentError' do
          expect { result }.to raise_error(ArgumentError)
        end
      end

      it 'builds correctly' do
        expect(result).to eq(
          [
            {
              content_type: 'text',
              title: 'Good!',
              payload: 'OK'
            },
            {
              content_type: 'text',
              title: 'Not so well',
              payload: 'NOT_OK'
            }
          ]
        )
      end
    end

    context 'when String passed' do
      let(:arguments) do
        ['ok']
      end

      it 'builds correctly' do
        expect(result).to eq(
          [
            {
              content_type: 'text',
              title: 'ok',
              payload: 'OK'
            }
          ]
        )
      end
    end
  end
end
