# frozen_string_literal: true

RSpec.describe Authorizy::Config do
  it 'starts with a default cop' do
    expect(subject.cop).to eq(Authorizy::BaseCop)
  end
end
