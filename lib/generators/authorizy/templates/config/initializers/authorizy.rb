# frozen_string_literal: true

Authorizy.configure do |config|
  # Creates aliases to automatically allow permission for another action.
  # https://github.com/wbotelhos/authorizy#aliases
  # config.aliases = {}

  # An interceptor to filter the request and decide if the request will be authorized
  # https://github.com/wbotelhos/authorizy#cop
  # config.cop = Authorizy::BaseCop

  # The current user from where we fetch the permissions
  # https://github.com/wbotelhos/authorizy#current-user
  # config.current_user = -> (context) { context.respond_to?(:current_user) ? context.current_user : nil }

  # Callback called when access is denied
  # https://github.com/wbotelhos/authorizy#denied
  # config.denied = lambda { |context|
  #   info = I18n.t('authorizy.denied', controller: context.params[:controller], action: context.params[:action])

  #   return context.render(json: { message: info }, status: 403) if context.request.xhr?

  #   context.redirect_to(redirect_url.call(self), info: info)
  # }

  # Inherited permissions from some other permission the user already has
  # https://github.com/wbotelhos/authorizy#dependencies
  # config.dependencies = {}

  # Field used to fetch the Authorizy permissions
  # https://github.com/wbotelhos/authorizy#field
  # config.field = ->(current_user) { current_user.respond_to?(:authorizy) ? current_user.authorizy : {} }

  # URL to be redirect when user has no permission to access some resource
  # https://github.com/wbotelhos/authorizy#dependencies
  # config.redirect_url = -> (context) { context.respond_to?(:root_url) ? context.root_url : '/' }
end
