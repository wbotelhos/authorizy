# frozen_string_literal: true

RSpec.describe Authorizy::Config, '#current_user' do
  let!(:config) { described_class.new }

  context 'when uses default value' do
    context 'when context responds to current_user' do
      let!(:context) { OpenStruct.new(current_user: 'user') }

      it 'is called' do
        expect(config.current_user.call(context)).to eq('user')
      end
    end

    context 'when context does not respond to current_user' do
      let!(:context) { 'context' }

      it 'returns nil' do
        expect(config.current_user.call(context)).to be(nil)
      end
    end
  end

  context 'when uses custom value' do
    it 'executes what you want' do
      config.current_user = ->(context) { context[:value] }

      expect(config.current_user.call({ value: 'value' })).to eq('value')
    end
  end
end
