# frozen_string_literal: true

RSpec.describe Authorizy::BaseCop, '#access?' do
  subject(:cop) { described_class.new('current_user', 'params', 'session', 'controller', 'action') }

  it 'returns false as default' do
    expect(cop.access?).to be(false)
  end
end
