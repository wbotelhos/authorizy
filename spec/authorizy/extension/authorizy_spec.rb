# frozen_string_literal: true

require 'support/controllers/dummy_controller'

RSpec.describe DummyController, '#authorizy', type: :controller do
  let!(:parameters) { ActionController::Parameters.new(key: 'value', controller: 'dummy', action: 'action') }
  let!(:user) { nil }

  context 'when user has access' do
    let!(:authorizy_core) { instance_double('Authorizy::Core', access?: true) }

    before do
      allow(Authorizy::Core).to receive(:new)
        .with(user, parameters, session, cop: Authorizy.config.cop)
        .and_return(authorizy_core)
    end

    context 'when is a xhr request' do
      it 'receives the default values and do not denied the access' do
        get :action, xhr: true, params: { key: 'value' }

        expect(response.body).to   eq('{"message":"authorized"}')
        expect(response.status).to be(200)
      end
    end

    context 'when is a html request' do
      it 'receives the default values and do not denied the access' do
        get :action, params: { key: 'value' }

        expect(response.body).to   eq('{"message":"authorized"}')
        expect(response.status).to be(200)
      end
    end
  end

  context 'when user has no access' do
    let!(:authorizy_core) { instance_double('Authorizy::Core', access?: false) }

    before do
      allow(Authorizy::Core).to receive(:new)
        .with(user, parameters, session, cop: Authorizy.config.cop)
        .and_return(authorizy_core)
    end

    it 'calls denied callback' do
      allow(Authorizy.config.denied).to receive(:call)

      get :action, xhr: true, params: { key: 'value' }

      expect(Authorizy.config.denied).to have_received(:call).with(subject)
    end
  end
end
