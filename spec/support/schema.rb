# frozen_string_literal: true

require 'active_record'
require 'support/models/user'

ActiveRecord::Base.establish_connection(
  adapter:  'postgresql',
  host:     'localhost',
  username: 'postgres',
)

ActiveRecord::Base.connection.execute('DROP DATABASE IF EXISTS authorizy_test;')
ActiveRecord::Base.connection.execute('CREATE DATABASE authorizy_test;')
ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS users;')

ActiveRecord::Schema.define(version: 1) do
  enable_extension 'plpgsql'

  create_table :users do |t|
    t.jsonb 'authorizy', default: {}
  end
end
