# frozen_string_literal: true

RSpec.describe Authorizy::Config, '#redirect_url' do
  let!(:config) { described_class.new }

  context 'when uses default value' do
    context 'when context responds to root_url' do
      let!(:context) { Struct.new(:root_url).new(root_url: '/root') }

      it 'is called' do
        expect(config.redirect_url.call(context)).to eq('/root')
      end
    end

    context 'when context does not respond to root_url' do
      let!(:context) { 'context' }

      it 'returns just a slash' do
        expect(config.redirect_url.call(context)).to eq('/')
      end
    end
  end

  context 'when uses custom value' do
    it 'executes what you want' do
      config.redirect_url = ->(context) { context[:key] }

      expect(config.redirect_url.call({ key: :value })).to eq(:value)
    end
  end
end
