# frozen_string_literal: true

RSpec.describe Authorizy::Config, '#dependencies' do
  subject(:config) { described_class.new }

  it 'has default value and can receive a new one' do
    expect(subject.dependencies).to eq({})

    config.dependencies = 'value'

    expect(config.dependencies).to eq('value')
  end
end
