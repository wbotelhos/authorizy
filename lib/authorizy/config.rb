# frozen_string_literal: true

module Authorizy
  class Config
    attr_accessor :aliases, :dependencies, :cop, :current_user, :redirect_url

    def initialize
      @aliases      = {}
      @cop          = Authorizy::BaseCop
      @current_user = -> (context) { context.respond_to?(:current_user) ? context.current_user : nil }
      @dependencies = {}
      @redirect_url = -> (context) { context.respond_to?(:root_url) ? context.root_url : '/' }
    end
  end
end
