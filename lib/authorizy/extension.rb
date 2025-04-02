# frozen_string_literal: true

module Authorizy
  module Extension
    extend ::ActiveSupport::Concern

    included do
      helper_method(:authorizy?)

      def authorizy
        return if Authorizy::Core.new(authorizy_user, params, session, cop: authorizy_cop).access?

        Authorizy.config.denied.call(self)
      end

      def authorizy?(controller, action, custom_params: {})
        params['controller'] = controller
        params['action'] = action

        parameters = params.merge(custom_params)
        cop = authorizy_cop(parameters)

        Authorizy::Core.new(authorizy_user, parameters, session, cop:).access?
      end

      private

      def authorizy_cop(parameters = params)
        Authorizy.config.cop.new(authorizy_user, parameters, session)
      end

      def authorizy_user
        Authorizy.config.current_user.call(self)
      end
    end
  end
end
