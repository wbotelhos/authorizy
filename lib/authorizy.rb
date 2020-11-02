# frozen_string_literal: true

module Authorizy
  require 'authorizy/base_cop'
  require 'authorizy/config'
  require 'authorizy/core'
  require 'authorizy/expander'
  require 'authorizy/extension'

  class << self
    def config
      @config ||= Authorizy::Config.new
    end

    def configure
      yield(config)
    end
  end
end
