# frozen_string_literal: true

RSpec.describe Authorizy, '.config' do
  it 'returns the config' do
    expect(described_class.config).to be_an_instance_of(Authorizy::Config)
  end
end
