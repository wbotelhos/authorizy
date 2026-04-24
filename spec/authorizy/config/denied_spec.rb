# frozen_string_literal: true

RSpec.describe Authorizy::Config, '#denied' do
  let!(:config) { described_class.new }

  context 'with default denied callback' do
    context 'when is not a html request' do
      let!(:format)  { Struct.new(:html?).new(false) }
      let!(:request) { Struct.new(:format).new(format) }
      let!(:context) { double('context', params: { controller: 'users', action: 'index' }, request:) }

      it 'renders' do
        allow(context).to receive(:render)

        config.denied.call(context)

        expect(context).to have_received(:render).with(json: { message: 'Action denied for users#index' }, status: 403)
      end
    end

    context 'when is a html request' do
      let!(:format)  { Struct.new(:html?).new(true) }
      let!(:request) { Struct.new(:format).new(format) }
      let!(:context) { double('context', params: { controller: 'users', action: 'index' }, request:, root_url: 'root_url') }

      it 'redirects' do
        allow(context).to receive(:redirect_to)
        allow(context).to receive(:respond_to?).with(:root_url).and_return(true)

        config.denied.call(context)

        expect(context).to have_received(:redirect_to).with('root_url', info: 'Action denied for users#index')
      end
    end
  end

  context 'with custom denied callback' do
    it 'calls the callback' do
      config.denied = ->(context) { context[:key] }

      expect(config.denied.call(key: :value)).to eq(:value)
    end
  end
end
