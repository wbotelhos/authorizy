# frozen_string_literal: true

RSpec.describe Authorizy::Config, '#cop' do
  subject(:config) { described_class.new }

  it 'has default value and can receive a new one' do
    expect(subject.cop).to eq(Authorizy::BaseCop)

    config.cop = 'value'

    expect(config.cop).to eq('value')
  end
end
