# frozen_string_literal: true

module Authorizy
  class Core
    def initialize(user, params, session, controller: params['controller'], action: params['action'], cop:)
      @action       = action.to_s
      @controller   = controller.to_s
      @cop          = cop
      @params       = params
      @session      = session
      @user         = user
    end

    def access?
      return false if @user.blank?

      return true if @cop.access?

      session_granted = session_permissions.any? { |tuple| route_match?(tuple) }

      return true if session_granted

      user_granted = user_permissions.any? { |tuple| route_match?(tuple) }

      return true if user_granted

      return @cop.public_send(cop_controller) if @cop.respond_to?(cop_controller)

      false
    end

    private

    def cop_controller
      @controller.sub('/', '__')
    end

    def expand(permissions)
      return [] if permissions.blank?

      Authorizy::Expander.new.expand(permissions)
    end

    def session_permissions
      expand(@session['permissions'])
    end

    def route_match?(tuple)
      tuple[0] == @controller && tuple[1] == @action
    end

    def user_permissions
      expand(@user.authorizy.try(:[], 'permissions'))
    end
  end
end
