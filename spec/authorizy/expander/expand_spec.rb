# frozen_string_literal: true

RSpec.describe Authorizy::Expander, '#expand' do
  subject(:expander) { described_class.new }

  context 'when permissions is blank' do
    let(:permissions) { [] }

    it 'returns an empty permissions' do
      expect(expander.expand(permissions)).to eq []
    end
  end

  context 'when permissions is given' do
    context 'when data is symbol' do
      let(:permissions) do
        [
          %i[controller create],
          %i[controller update],
        ]
      end

      it 'maps the default actions aliases' do
        expect(expander.expand(permissions)).to match_array [
          %w[controller create],
          %w[controller edit],
          %w[controller new],
          %w[controller update],
        ]
      end
    end

    context 'when data is string' do
      let(:permissions) do
        [
          %w[controller create],
          %w[controller update],
        ]
      end

      it 'maps the default actions aliases' do
        expect(expander.expand(permissions)).to match_array [
          %w[controller create],
          %w[controller edit],
          %w[controller new],
          %w[controller update],
        ]
      end
    end
  end

  context 'when a dependencies is given' do
    context 'when keys and values are strings' do
      let(:dependencies) { { 'controller' => { 'action' => [%w[controller_2 action_2]] } } }
      let!(:permissions) { [%w[controller action]] }

      it 'addes the dependencies permissions' do
        config_mock(dependencies: dependencies) do
          expect(expander.expand(permissions)).to match_array [
            %w[controller action],
            %w[controller_2 action_2],
          ]
        end
      end
    end

    context 'when keys and values are symbol' do
      let(:dependencies) { { controller: { action: [%i[controller_2 action_2]] } } }
      let!(:permissions) { [%w[controller action]] }

      it 'addes the dependencies permissions' do
        config_mock(dependencies: dependencies) do
          expect(expander.expand(permissions)).to match_array [
            %w[controller action],
            %w[controller_2 action_2],
          ]
        end
      end
    end
  end

  context 'when aliases is given' do
    let!(:permissions) { [%w[controller action]] }

    context 'when key and values are strings' do
      let(:aliases) { { 'action' => 'action_2' } }

      it 'maps the action with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            %w[controller action],
            %w[controller action_2],
          ]
        end
      end
    end

    context 'when key and values are symbols' do
      let(:aliases) { { action: :action_2 } }

      it 'maps the action with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            %w[controller action],
            %w[controller action_2],
          ]
        end
      end
    end

    context 'when key and values are array of strings' do
      let(:aliases) { { action: %w[action_2 action_3] } }

      it 'maps the actions with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            %w[controller action],
            %w[controller action_2],
            %w[controller action_3],
          ]
        end
      end
    end

    context 'when key and values are array of symbols' do
      let(:aliases) { { action: %i[action_2 action_3] } }

      it 'maps the actions with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            %w[controller action],
            %w[controller action_2],
            %w[controller action_3],
          ]
        end
      end
    end
  end
end
