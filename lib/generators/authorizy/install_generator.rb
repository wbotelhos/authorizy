# frozen_string_literal: true

module Authorizy
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc 'Creates Initializer and Migration for Authorizy'

    def create_initializer
      copy_file 'config/initializers/authorizy.rb', 'config/initializers/authorizy.rb'
    end

    def create_migration
      copy_file 'db/migrate/add_authorizy_on_users.rb', "db/migrate/#{timestamp(0)}_add_authorizy_on_users.rb"
    end

    private

    def timestamp(seconds)
      (Time.current + seconds.seconds).strftime('%Y%m%d%H%M%S')
    end
  end
end
