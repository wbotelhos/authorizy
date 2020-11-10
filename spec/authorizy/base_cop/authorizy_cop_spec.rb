# frozen_string_literal: true

require 'support/models/authorizy_cop'

RSpec.describe AuthorizyCop do
  subject(:cop) { described_class.new('current_user', 'params', 'session', 'controller', 'action') }

  it 'adds private attributes readers' do
    expect(cop.get_action).to       eq('action')
    expect(cop.get_controller).to   eq('controller')
    expect(cop.get_current_user).to eq('current_user')
    expect(cop.get_params).to       eq('params')
    expect(cop.get_session).to      eq('session')
  end
end
