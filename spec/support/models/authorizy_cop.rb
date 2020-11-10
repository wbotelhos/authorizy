# frozen_string_literal: true

class AuthorizyCop < Authorizy::BaseCop
  def dummy
    params[:access] == 'true'
  end

  def get_action
    action
  end

  def get_controller
    controller
  end

  def get_current_user
    current_user
  end

  def get_params
    params
  end

  def get_session
    session
  end
end
