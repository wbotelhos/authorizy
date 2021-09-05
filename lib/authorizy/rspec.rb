# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :be_authorized do |controller, action, params: {}, session: {}|
  match do |user|
    parameters = params.stringify_keys.merge('controller' => controller, 'action' => action)

    access?(user, parameters, session)
  end

  match_when_negated do |user|
    parameters = params.stringify_keys.merge('controller' => controller, 'action' => action)

    !access?(user, parameters, session)
  end

  failure_message do |user|
    maybe_params_or_session("expected #{user.class}##{user.id} to be authorized in #{data}", params, session)
  end

  failure_message_when_negated do |user|
    maybe_params_or_session("expected #{user.class}##{user.id} not to be authorized in #{data}", params, session)
  end

  private

  def access?(user, parameters, session)
    Authorizy::Core.new(user, parameters, session).access?
  end

  def maybe_params_or_session(message, params, session)
    message += " with params: #{params}" if params.present?
    message += " with session: #{session}" if session.present?

    message
  end

  def data
    'controller: ' # {expected[0]}", action: "#{expected[1]}")
  end
end
