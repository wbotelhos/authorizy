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
          { action: :create, controller: :controller },
          { action: :edit, controller: :controller },
          { action: :new, controller: :controller },
          { action: :update, controller: :controller },
        ]
      end

      it 'mappes the default actions aliases' do
        expect(expander.expand(permissions)).to match_array [
          { 'action' => 'create', 'controller' => 'controller' },
          { 'action' => 'edit',   'controller' => 'controller' },
          { 'action' => 'new',    'controller' => 'controller' },
          { 'action' => 'update', 'controller' => 'controller' },
        ]
      end
    end

    context 'when data is string' do
      let(:permissions) do
        [
          { 'action' => 'create', 'controller' => 'controller' },
          { 'action' => 'edit', 'controller' => 'controller' },
          { 'action' => 'new', 'controller' => 'controller' },
          { 'action' => 'update', 'controller' => 'controller' },
        ]
      end

      it 'mappes the default actions aliases' do
        expect(expander.expand(permissions)).to match_array [
          { 'action' => 'create', 'controller' => 'controller' },
          { 'action' => 'edit',   'controller' => 'controller' },
          { 'action' => 'new',    'controller' => 'controller' },
          { 'action' => 'update', 'controller' => 'controller' },
        ]
      end
    end
  end

  context 'when a dependencies is given' do
    context 'when keys and values are strings' do
      let(:dependencies) { { 'controller' => { 'action' => [{ 'action' => 'action2', 'controller' => 'controller2' }] } } }
      let!(:permissions) { [{ 'action' => 'action', 'controller' => 'controller' }] }

      it 'addes the dependencies permissions' do
        config_mock(dependencies: dependencies) do
          expect(expander.expand(permissions)).to match_array [
            { 'action' => 'action', 'controller' => 'controller' },
            { 'action' => 'action2', 'controller' => 'controller2' },
          ]
        end
      end
    end

    context 'when keys and values are symbol' do
      let(:dependencies) { { controller: { action: [{ action: :action2, controller: :controller2 }] } } }
      let!(:permissions) { [{ 'action' => 'action', 'controller' => 'controller' }] }

      it 'addes the dependencies permissions' do
        config_mock(dependencies: dependencies) do
          expect(expander.expand(permissions)).to match_array [
            { 'action' => 'action', 'controller' => 'controller' },
            { 'action' => 'action2', 'controller' => 'controller2' },
          ]
        end
      end
    end
  end


  context 'when aliases is given' do
    let!(:permissions) { [{ 'action' => 'action', 'controller' => 'controller' }] }

    context 'when key and values are strings' do
      let(:aliases) { { 'action' => 'action2' } }

      it 'mappes the action with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            { 'action' => 'action', 'controller' => 'controller' },
            { 'action' => 'action2', 'controller' => 'controller' },
          ]
        end
      end
    end

    context 'when key and values are symbols' do
      let(:aliases) { { action: :action2 } }

      it 'mappes the action with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            { 'action' => 'action', 'controller' => 'controller' },
            { 'action' => 'action2', 'controller' => 'controller' },
          ]
        end
      end
    end

    context 'when key and values are array of strings' do
      let(:aliases) { { action: %w[action2 action3] } }

      it 'mappes the actions with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            { 'action' => 'action', 'controller' => 'controller' },
            { 'action' => 'action2', 'controller' => 'controller' },
            { 'action' => 'action3', 'controller' => 'controller' },
          ]
        end
      end
    end

    context 'when key and values are array of symbols' do
      let(:aliases) { { action: %i[action2 action3] } }

      it 'mappes the actions with the current controller' do
        config_mock(aliases: aliases) do
          expect(expander.expand(permissions)).to match_array [
            { 'action' => 'action', 'controller' => 'controller' },
            { 'action' => 'action2', 'controller' => 'controller' },
            { 'action' => 'action3', 'controller' => 'controller' },
          ]
        end
      end
    end
  end
end
