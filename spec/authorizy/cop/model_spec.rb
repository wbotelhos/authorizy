# frozen_string_literal: true

require 'support/models/authorizy_cop'

RSpec.describe AuthorizyCop do
  subject(:cop) { described_class.new('current_user', 'params', 'session', 'controller', 'action') }

  it 'adds private attributes readers' do
    expect(cop.fetch_action).to       eq('action')
    expect(cop.fetch_controller).to   eq('controller')
    expect(cop.fetch_current_user).to eq('current_user')
    expect(cop.fetch_params).to       eq('params')
    expect(cop.fetch_session).to      eq('session')
  end
end
