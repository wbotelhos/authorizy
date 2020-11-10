# frozen_string_literal: true

require 'support/models/authorizy_cop'
require 'support/controllers/dummy_controller'

RSpec.describe DummyController, '#authorizy', type: :controller do
  let!(:parameters) { ActionController::Parameters.new(key: 'value', controller: 'dummy', action: 'action') }

  Rails.application.routes.draw { get :action, to: 'dummy#action' }

  let!(:authorizy_core) { instance_double('Authorizy::Core', access?: false) }
  let!(:user) { User.new }

  context 'when cop responds to the controller name' do
    context 'when method resturns false' do
      let!(:access) { false }

      it 'denies the access' do
        config_mock(cop: AuthorizyCop, current_user: user) do
          get :action, params: { access: access }
        end

        expect(response).to redirect_to('/')
      end
    end

    context 'when method resturns true' do
      let!(:access) { true }

      it 'denies the access' do
        config_mock(cop: AuthorizyCop, current_user: user) do
          get :action, params: { access: access }
        end

        expect(response.body).to eq('{"message":"authorized"}')
      end
    end
  end
end
