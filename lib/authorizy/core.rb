# frozen_string_literal: true

module Authorizy
  class Core
    def initialize(user, params, session, cop:)
      @cop     = cop
      @params  = params
      @session = session
      @user    = user
    end

    def access?
      return false if @user.blank?

      return true if @cop.access? ||
                     session_permissions.any? { |tuple| route_match?(tuple) } ||
                     user_permissions.any? { |tuple| route_match?(tuple) }

      return @cop.public_send(cop_controller) if @cop.respond_to?(cop_controller)

      false
    end

    private

    def action
      @params[:action].to_s
    end

    def controller
      @params[:controller].to_s
    end

    def cop_controller
      controller.sub('/', '__')
    end

    def expand(permissions)
      return [] if permissions.blank?

      Authorizy::Expander.new.expand(permissions)
    end

    def session_permissions
      expand(@session[:permissions])
    end

    def route_match?(tuple)
      tuple[0] == controller && tuple[1] == action
    end

    def user_permissions
      expand(@user.authorizy.try(:[], 'permissions'))
    end
  end
end
