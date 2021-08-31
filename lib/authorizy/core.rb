# frozen_string_literal: true

module Authorizy
  class Core
    def initialize(current_user, params, session, controller: params['controller'], action: params['action'])
      @action       = action.to_s
      @controller   = controller.to_s
      @current_user = current_user
      @params       = params
      @session      = session
    end

    def access?
      return false if @current_user.blank?

      return true if cop.access?

      session_granted = session_permissions.map(&:stringify_keys).any? { |item| route_match?(item) }

      return true if session_granted

      current_user_granted = current_user_permissions.map(&:stringify_keys).any? { |item| route_match?(item) }

      return true if current_user_granted

      return cop.public_send(cop_controller) if cop.respond_to?(cop_controller)

      false
    end

    private

    def cop
      Authorizy.config.cop.new(@current_user, @params, @session, @controller, @action)
    end

    def cop_controller
      @controller.sub('/', '__')
    end

    def expand(permissions)
      return [] if permissions.blank?

      Authorizy::Expander.new.expand(permissions)
    end

    def session_permissions
      expand([@session['permissions']].flatten.compact)
    end

    def current_user_permissions
      expand(@current_user.authorizy.try(:[], 'permissions'))
    end

    def route_match?(item)
      item['controller'].to_s == @controller && item['action'].to_s == @action
    end
  end
end
