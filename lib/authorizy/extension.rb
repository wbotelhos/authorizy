# frozen_string_literal: true

module Authorizy
  module Extension
    extend ::ActiveSupport::Concern

    included do
      def authorizy
        return if Authorizy::Core.new(Authorizy.config.current_user.call(self), params, session).access?

        info = I18n.t('authorizy.denied', action: params[:action], controller: params[:controller])

        return render(json: { message: info }, status: 422) if request.xhr?

        redirect_to Authorizy.config.redirect_url.call(self), info: info
      end
    end
  end
end
