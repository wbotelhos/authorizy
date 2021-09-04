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
          [:controller, :create],
          [:controller, :update],
        ]
      end

      it 'maps the default actions aliases' do
        expect(expander.expand(permissions)).to match_array [
          ['controller', 'create'],
          ['controller', 'edit'],
          ['controller', 'new'],
          ['controller', 'update'],
        ]
      end
    end

    context 'when data is string' do
      let(:permissions) do
        [
          ['controller', 'create'],
          ['controller', 'update'],
        ]
      end

      it 'maps the default actions aliases' do
        expect(expander.expand(permissions)).to match_array [
          ['controller', 'create'],
          ['controller', 'edit'],
          ['controller', 'new'],
          ['controller', 'update'],
        ]
      end
    end
  end

  context 'when a dependencies is given' do
    context 'when keys and values are strings' do
      let(:dependencies) { { 'controller' => { 'action' => [['controller2', 'action2']] } } }
      let!(:permissions) { [['controller', 'action']] }

      it 'addes the dependencies permissions' do
        config_mock(dependencies: dependencies) do
          expect(expander.expand(permissions)).to match_array [
            ['controller', 'action'],
            ['controller2', 'action2'],
          ]
        end
      end
    end

    context 'when keys and values are symbol' do
      let(:dependencies) { { controller: { action: [[:controller2, :action2]] } } }
      let!(:permissions) { [['controller', 'action']] }

      it 'addes the dependencies permissions' do
        config_mock(dependencies: dependencies) do
          expect(expander.expand(permissions)).to match_array [
            ['controller', 'action'],
            ['controller2', 'action2'],
          ]
        end
      end
    end
  end

  context 'when aliases is given' do
    let!(:permissions) { [['controller', 'action']] }

    context 'when key and values are strings' do
      let(:aliases) { { 'action' => 'action2' } }

      it 'maps the action with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            ['controller', 'action'],
            ['controller', 'action2'],
          ]
        end
      end
    end

    context 'when key and values are symbols' do
      let(:aliases) { { action: :action2 } }

      it 'maps the action with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            ['controller', 'action'],
            ['controller', 'action2'],
          ]
        end
      end
    end

    context 'when key and values are array of strings' do
      let(:aliases) { { action: %w[action2 action3] } }

      it 'maps the actions with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            ['controller', 'action'],
            ['controller', 'action2'],
            ['controller', 'action3'],
          ]
        end
      end
    end

    context 'when key and values are array of symbols' do
      let(:aliases) { { action: %i[action2 action3] } }

      it 'maps the actions with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            ['controller', 'action'],
            ['controller', 'action2'],
            ['controller', 'action3'],
          ]
        end
      end
    end
  end
end
