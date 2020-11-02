# frozen_string_literal: true

require 'rspec'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random
end
