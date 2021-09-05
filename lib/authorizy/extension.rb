# frozen_string_literal: true

module Authorizy
  module Extension
    extend ::ActiveSupport::Concern

    included do
      helper_method(:authorizy?)

      def authorizy
        return if authorizy_core.new(authorizy_user, params, session, cop: authorizy_cop).access?

        info = I18n.t('authorizy.denied', controller: params[:controller], action: params[:action])

        return render(json: { message: info }, status: 401) if request.xhr?

        redirect_to authorizy_config.redirect_url.call(self), info: info
      end

      def authorizy?(controller, action)
        params['controller'] = controller
        params['action'] = action

        authorizy_core.new(authorizy_user, params, session, cop: authorizy_cop).access?
      end

      private

      def authorizy_core
        Authorizy::Core
      end

      def authorizy_user
        authorizy_config.current_user.call(self)
      end

      def authorizy_config
        Authorizy.config
      end

      def authorizy_cop
        authorizy_config.cop.new(authorizy_user, params, session)
      end
    end
  end
end
