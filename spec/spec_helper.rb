# frozen_string_literal: true

def config_mock(aliases: nil, current_user: nil, dependencies: nil, redirect_url: nil)
  backup = {
    aliases:      Authorizy.config.aliases,
    current_user: Authorizy.config.current_user,
    dependencies: Authorizy.config.dependencies,
    redirect_url: Authorizy.config.redirect_url,
  }

  Authorizy.configure do |config|
    config.aliases      = aliases      if aliases
    config.current_user = current_user if current_user
    config.dependencies = dependencies if dependencies
    config.redirect_url = redirect_url if redirect_url
  end

  yield
ensure
  Authorizy.configure do |config|
    config.aliases      = backup[:aliases]
    config.current_user = backup[:current_user]
    config.dependencies = backup[:dependencies]
    config.redirect_url = backup[:redirect_url]
  end
end
