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

      granted = permissions.any? do |item|
        data = item.stringify_keys

        data['controller'].to_s == @controller && data['action'].to_s == @action
      end

      return true if granted

      cop.respond_to?(cop_controller) && cop.public_send(cop_controller)
    end

    private

    def cop
      Authorizy.config.cop.new(@current_user, @params, @session, @controller, @action)
    end

    def cop_controller
      @controller.sub('/', '__')
    end

    def permissions
      Authorizy::Expander.new.expand(
        [@session['permissions']].flatten.compact.presence || @current_user.authorizy.try(:[], 'permissions')
      )
    end
  end
end
