# frozen_string_literal: true

RSpec.describe RSpec::Matchers, '#be_authorized' do
  it 'pending' do
    matcher = be_authorized('controller', 'action', params: { params: true }, session: { session: true })

    expect(matcher.description).to eq %(
      be authorized "controller", "action", and {:params=>{:params=>true}, :session=>{:session=>true}}
    ).squish
  end
end
