# frozen_string_literal: true

class AddAuthorizyOnUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :authorizy, :jsonb, default: {}, null: false
  end
end
