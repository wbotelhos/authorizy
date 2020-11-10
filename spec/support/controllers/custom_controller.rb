# frozen_string_literal: true

class CustomController < ActionController::Base
  include Authorizy::Extension

  before_action :authorizy

  def action
    render json: { message: 'authorized' }
  end

  def authorizy_aliases
    { index: 'gridy' }
  end

  def authorizy_dependencies
    {
      'admin/payments' => {
        index: [
          { action: :show, controller: 'admin/payments' },
        ],
      },
    }
  end

  def authorizy_redirect_url
    '/login'
  end

  def current_user
    User.last
  end
end
