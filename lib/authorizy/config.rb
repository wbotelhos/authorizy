# frozen_string_literal: true

module Authorizy
  class Config
    attr_accessor :aliases, :cop, :current_user, :dependencies, :field, :redirect_url

    def initialize
      @aliases      = {}
      @cop          = Authorizy::BaseCop
      @current_user = ->(context) { context.respond_to?(:current_user) ? context.current_user : nil }
      @dependencies = {}
      @field        = ->(current_user) { current_user.respond_to?(:authorizy) ? current_user.authorizy : {} }
      @redirect_url = ->(context) { context.respond_to?(:root_url) ? context.root_url : '/' }
    end
  end
end
