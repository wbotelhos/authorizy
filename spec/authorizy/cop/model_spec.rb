# frozen_string_literal: true

require 'support/models/authorizy_cop'

RSpec.describe AuthorizyCop do
  let!(:params) { { controller: 'controller', action: 'action' } }
  let(:cop) { described_class.new('current_user', params, 'session') }

  it 'adds private attributes readers' do
    expect(cop.fetch_action).to       eq('action')
    expect(cop.fetch_controller).to   eq('controller')
    expect(cop.fetch_current_user).to eq('current_user')
    expect(cop.fetch_params).to       eq(controller: 'controller', action: 'action')
    expect(cop.fetch_session).to      eq('session')
  end
end
