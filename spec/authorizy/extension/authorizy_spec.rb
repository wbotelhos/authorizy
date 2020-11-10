# frozen_string_literal: true

require 'support/controllers/dummy_controller'

RSpec.describe DummyController, '#authorizy', type: :controller do
  let!(:parameters) { ActionController::Parameters.new(key: 'value', controller: 'dummy', action: 'action') }

  Rails.application.routes.draw { get :action, to: 'dummy#action' }

  context 'when user has access' do
    let!(:authorizy_core) { instance_double('Authorizy::Core', access?: true) }

    before { allow(Authorizy::Core).to receive(:new).with(nil, parameters, session).and_return(authorizy_core) }

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

    before { allow(Authorizy::Core).to receive(:new).with(nil, parameters, session).and_return(authorizy_core) }

    context 'when is a xhr request' do
      it 'receives the default values and denied the access' do
        get :action, xhr: true, params: { key: 'value' }

        expect(response.body).to   eq('{"message":"Action denied for dummy#action"}')
        expect(response.status).to be(422)
      end
    end

    context 'when is a html request' do
      it 'receives the default values and do not denied the access' do
        get :action, params: { key: 'value' }

        expect(response).to redirect_to '/'

        # expect(flash[:info]).to eq('Action denied for dummy#action') # TODO: get flash message
      end
    end
  end
end
