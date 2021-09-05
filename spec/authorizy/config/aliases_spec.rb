# frozen_string_literal: true

RSpec.describe Authorizy::Config, '#aliases' do
  let!(:config) { described_class.new }

  it 'has default value and can receive a new one' do
    expect(config.aliases).to eq({})

    config.aliases = 'value'

    expect(config.aliases).to eq('value')
  end
end
