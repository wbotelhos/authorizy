# frozen_string_literal: true

RSpec.describe Authorizy, '.configure' do
  it 'yields the config' do
    described_class.configure do |config|
      expect(config).to be_an_instance_of(Authorizy::Config)
    end
  end
end
