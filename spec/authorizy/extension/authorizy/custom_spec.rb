# frozen_string_literal: true

require 'support/controllers/custom_controller'

RSpec.describe CustomController, '#authorizy', type: :controller do
  before do
    Rails.application.routes.draw { get :action, to: 'custom#action' }
  end

  let!(:aliases) { { index: 'gridy' } }
  let!(:parameters) { ActionController::Parameters.new(key: 'value', controller: 'custom', action: 'action') }
  let!(:user) { User.create! }

  let!(:dependencies) do
    {
      'admin/payments' => {
        index: [
          { action: :show, controller: 'admin/payments' },
        ],
      },
    }
  end

  context 'when user has access' do
    let!(:authorizy_core) { instance_double('Authorizy::Core', access?: true) }

    before do
      allow(Authorizy::Core).to receive(:new)
        .with(user, parameters, session, aliases: aliases, dependencies: dependencies)
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
        .with(user, parameters, session, aliases: aliases, dependencies: dependencies)
        .and_return(authorizy_core)
    end

    context 'when is a xhr request' do
      it 'receives the default values and denied the access' do
        get :action, xhr: true, params: { key: 'value' }

        expect(response.body).to   eq('{"message":"Action denied for custom#action"}')
        expect(response.status).to be(422)
      end
    end

    context 'when is a html request' do
      it 'receives the default values and do not denied the access' do
        get :action, params: { key: 'value' }

        expect(response).to redirect_to '/login'

        # expect(flash[:info]).to eq('Action denied for custom#action') # TODO: get flash message
      end
    end
  end

  it 'exposes helper methods' do
    expect(controller.helpers.authorizy_aliases).to eq(index: 'gridy')

    expect(controller.helpers.authorizy_dependencies).to eq(
      'admin/payments' => {
        index: [
          { action: :show, controller: 'admin/payments' },
        ],
      }
    )
  end
end
