# frozen_string_literal: true

RSpec.describe Authorizy::Config, '#denied' do
  let!(:config) { described_class.new }

  context 'with default denied callback' do
    context 'when is a xhr request' do
      let!(:context) do
        double('context',
          params: { controller: 'users', action: 'index' },
          request: Struct.new(:xhr?).new(xhr?: true)
        )
      end

      it 'renders' do
        allow(context).to receive(:render)

        config.denied.call(context)

        expect(context).to have_received(:render).with(json: { message: 'Action denied for users#index' }, status: 403)
      end
    end

    context 'when is not a xhr request' do
      let!(:context) do
        double('context',
          params: { controller: 'users', action: 'index' },
          request: Struct.new(:xhr?).new(xhr?: false),
          root_url: 'root_url'
        )
      end

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
