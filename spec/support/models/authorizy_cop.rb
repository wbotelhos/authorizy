# frozen_string_literal: true

class AuthorizyCop < Authorizy::BaseCop
  def admin__dummy
    params[:admin] == 'true'
  end

  def custom_params
    params[:custom] == 'true'
  end

  def dummy
    params[:access] == 'true'
  end

  def fetch_action
    action
  end

  def fetch_controller
    controller
  end

  def fetch_current_user
    current_user
  end

  def fetch_params
    params
  end

  def fetch_session
    session
  end
end
