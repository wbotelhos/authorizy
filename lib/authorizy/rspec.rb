# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :be_authorized do |controller, action, params: {}, session: {}|
  match do |user|
    parameters = params.merge(controller:, action:)

    access?(user, parameters, session)
  end

  match_when_negated do |user|
    parameters = params.merge(controller:, action:)

    !access?(user, parameters, session)
  end

  failure_message do |user|
    maybe_params_or_session("expected #{user.class}##{user.id} to be authorized in #{data}", params, session)
  end

  failure_message_when_negated do |user|
    maybe_params_or_session("expected #{user.class}##{user.id} not to be authorized in #{data}", params, session)
  end

  description do
    parts = [%(be authorized "#{expected[0]}", "#{expected[1]}")]

    options = [].tap do |item|
      item << "params: #{format_hash(params)}" if params.any?
      item << "session: #{format_hash(session)}" if session.any?
    end

    parts << "and {#{options.join(', ')}}" if options.any?

    parts.join(', ')
  end

  private

  def format_hash(hash)
    pairs = hash.map { |k, v| "#{k}: #{v.is_a?(Hash) ? format_hash(v) : v.inspect}" }

    "{#{pairs.join(', ')}}"
  end

  def access?(user, params, session)
    cop = Authorizy.config.cop.new(user, params, session)

    Authorizy::Core.new(user, params, session, cop:).access?
  end

  def maybe_params_or_session(message, params, session)
    message += ", params: #{params}" if params.present?
    message += ", session: #{session}" if session.present?

    message
  end

  def data
    %(controller: "#{expected[0]}", action: "#{expected[1]}")
  end
end
