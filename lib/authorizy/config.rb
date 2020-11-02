# frozen_string_literal: true

module Authorizy
  class Config
    attr_accessor :cop

    def initialize
      @cop = Authorizy::BaseCop
    end
  end
end
