# frozen_string_literal: true

require 'authorizy/rspec'
require 'support/models/authorizy_cop'

RSpec.describe RSpec::Matchers, '#be_authorized' do
  it 'builds the correct description' do
    matcher = be_authorized('controller', 'action', params: { params: true }, session: { session: true })

    expect(matcher.description).to eq %(
      be authorized "controller", "action", and {:params=>{:params=>true}, :session=>{:session=>true}}
    ).squish
  end

  it 'has the positive question helper method' do
    user = User.new

    config_mock(cop: AuthorizyCop, current_user: user) do
      expect(user).to be_authorized('dummy', 'any', params: { access: 'true' })
    end
  end

  it 'has the negative question helper method' do
    user = User.new

    config_mock(cop: AuthorizyCop, current_user: user) do
      expect(user).not_to be_authorized('dummy', 'any', params: { access: 'false' })
    end
  end
end
