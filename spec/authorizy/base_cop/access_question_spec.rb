# frozen_string_literal: true

RSpec.describe Authorizy::BaseCop, '#access?' do
  let!(:params) { { 'controller' => 'controller', 'action' => 'action' } }
  let(:cop) { described_class.new('current_user', params, 'session') }

  it 'returns false as default' do
    expect(cop.access?).to be(false)
  end
end
