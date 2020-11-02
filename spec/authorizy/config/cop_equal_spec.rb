# frozen_string_literal: true

RSpec.describe Authorizy::Config, '#cop=' do
  subject(:config) { described_class.new }

  let!(:cop) { double }

  it 'changes the cop' do
    config.cop = cop

    expect(config.cop).to eq(cop)
  end
end
