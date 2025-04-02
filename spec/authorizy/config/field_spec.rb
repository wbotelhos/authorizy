# frozen_string_literal: true

RSpec.describe Authorizy::Config, '#field' do
  let!(:config) { described_class.new }

  context 'when uses default value' do
    context 'when current_user responds to authorizy' do
      let!(:current_user) { Struct.new(:authorizy).new(authorizy: { permissions: [%i[users index]] }) }

      it 'is called' do
        expect(config.field.call(current_user)).to eq(permissions: [%i[users index]])
      end
    end

    context 'when current_user does not respond to field' do
      let!(:current_user) { nil }

      it { expect(config.field.call(current_user)).to eq({}) }
    end
  end

  context 'when uses custom value' do
    it 'executes what you want' do
      config.field = ->(current_user) { current_user[:value] }

      expect(config.field.call({ value: 'value' })).to eq('value')
    end
  end
end
