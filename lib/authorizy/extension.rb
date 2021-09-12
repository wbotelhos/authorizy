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

      def authorizy?(controller, action)
        params['controller'] = controller
        params['action'] = action

        Authorizy::Core.new(authorizy_user, params, session, cop: authorizy_cop).access?
      end

      private

      def authorizy_user
        Authorizy.config.current_user.call(self)
      end

      def authorizy_cop
        Authorizy.config.cop.new(authorizy_user, params, session)
      end
    end
  end
end
