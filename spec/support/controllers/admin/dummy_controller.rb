# frozen_string_literal: true

module Admin
  class DummyController < ActionController::Base
    include Authorizy::Extension

    before_action :authorizy

    def action
      render json: { message: 'authorized' }
    end
  end
end
