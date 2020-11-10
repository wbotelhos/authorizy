# frozen_string_literal: true

require 'support/controllers/default_controller'

RSpec.describe DefaultController, '#authorizy', type: :controller do
  before do
    Rails.application.routes.draw { get :action, to: 'default#action' }
  end

  let!(:parameters) { ActionController::Parameters.new(key: 'value', controller: 'default', action: 'action') }

  context 'when user has access' do
    let!(:authorizy_core) { instance_double('Authorizy::Core', access?: true) }

    before do
      allow(Authorizy::Core).to receive(:new)
        .with(nil, parameters, session, aliases: {}, dependencies: {})
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
        .with(nil, parameters, session, aliases: {}, dependencies: {})
        .and_return(authorizy_core)
    end

    context 'when is a xhr request' do
      it 'receives the default values and denied the access' do
        get :action, xhr: true, params: { key: 'value' }

        expect(response.body).to   eq('{"message":"Action denied for default#action"}')
        expect(response.status).to be(422)
      end
    end

    context 'when is a html request' do
      it 'receives the default values and do not denied the access' do
        get :action, params: { key: 'value' }

        expect(response).to redirect_to '/'

        # expect(flash[:info]).to eq('Action denied for default#action') # TODO: get flash message
      end
    end
  end

  it 'does not expose aliases helper methods' do
    controller.helpers.authorizy_aliases

    fail('method `authorizy_aliases` should not exists')
  rescue NoMethodError => e
  end

  it 'does not expose aliases helper methods' do
    controller.helpers.authorizy_dependencies

    fail('method `authorizy_dependencies` should not exists')
  rescue NoMethodError => e
  end
end
