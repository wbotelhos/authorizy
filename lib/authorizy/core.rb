# frozen_string_literal: true

module Authorizy
  class Core
    def initialize(user, params, session, cop: nil)
      @cop     = cop
      @params  = params
      @session = session
      @user    = user
    end

    def access?
      return false if @user.blank?

      return true if @cop&.access?
      return true if session_permissions.any? { |tuple| route_match?(tuple) }
      return true if user_permissions.any? { |tuple| route_match?(tuple) }

      return false unless @cop.respond_to?(cop_controller)

      @cop.public_send(cop_controller) == true
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
      expand(Authorizy.config.field.call(@user).try(:[], 'permissions'))
    end
  end
end
