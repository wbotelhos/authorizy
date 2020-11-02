# frozen_string_literal: true

module Authorizy
  class Extension
    extend ::ActiveSupport::Concern

    included do
      helper_method(:authorizy_aliases) if defined?(:authorizy_aliases)
      helper_method(:authorizy_dependencies) if defined?(:authorizy_dependencies)

      def authorizy(aliases: default_aliases, dependencies: default_dependencies, redirect_url: default_redirect_url)
        return if Authorizy::Core.new(current_user, params, session, aliases: aliases, dependencies: dependencies).access?

        info = I18n.t('authorizy.denied', action: params[:action], controller: params[:controller])

        return render(json: { message: info }, status: 422) if request.xhr?

        redirect_to redirect_url, info: info
      end

      private

      def default_aliases
        respond_to?(:authorizy_aliases) ? send(:authorizy_aliases) : {}
      end

      def default_dependencies
        respond_to?(:authorizy_dependencies) ? send(:authorizy_dependencies) : {}
      end

      def default_redirect_url
        respond_to?(:authorizy_redirect_url) ? send(:authorizy_redirect_url) : root_url
      end
    end

    module ClassMethods
      # def autorizy(options = {})
      # end
    end
  end
end
