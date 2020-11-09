# frozen_string_literal: true

RSpec.describe Authorizy::BaseCop, '#access?' do
  subject(:cop) { described_class.new('action', 'controller', 'current_user', 'params', 'session') }

  it 'returns false as default' do
    expect(cop.access?).to be(false)
  end
end
