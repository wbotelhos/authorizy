# frozen_string_literal: true

module Authorizy
  class BaseCop
    def initialize(current_user, params, session, controller, action)
      @action       = action
      @controller   = controller
      @current_user = current_user
      @params       = params
      @session      = session
    end

    def access?
      false
    end
  end
end
