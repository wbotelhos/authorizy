# frozen_string_literal: true

module Authorizy
  module Extension
    extend ::ActiveSupport::Concern

    included do
      helper_method(:authorizy?)

      def authorizy
        return if Authorizy::Core.new(authorizy_user, params, session).access?

        info = I18n.t('authorizy.denied', action: params[:action], controller: params[:controller])

        return render(json: { message: info }, status: 422) if request.xhr?

        redirect_to Authorizy.config.redirect_url.call(self), info: info
      end

      def authorizy?(controller, action)
        Authorizy::Core.new(authorizy_user, params, session, action: action, controller: controller).access?
      end

      private

      def authorizy_user
        Authorizy.config.current_user.call(self)
      end
    end
  end
end
