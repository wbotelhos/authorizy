# frozen_string_literal: true

require 'active_record'
require 'support/models/user'

ActiveRecord::Base.establish_connection(
  adapter:  'postgresql',
  database: 'authorizy_test',
  host:     'localhost',
  username: 'postgres',
)

ActiveRecord::Base.connection.execute('DROP TABLE users;')

ActiveRecord::Schema.define(version: 1) do
  enable_extension 'plpgsql'

  create_table :users do |t|
    t.jsonb 'authorizy', default: {}
  end
end
