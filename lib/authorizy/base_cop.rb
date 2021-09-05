# frozen_string_literal: true

module Authorizy
  class BaseCop
    def initialize(current_user, params, session)
      @action       = params[:action].to_s
      @controller   = params[:controller].to_s
      @current_user = current_user
      @params       = params
      @session      = session
    end

    def access?
      false
    end

    protected

    attr_reader :action, :controller, :current_user, :params, :session
  end
end
