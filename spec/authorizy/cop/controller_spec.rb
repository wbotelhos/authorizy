# frozen_string_literal: true

require 'support/models/authorizy_cop'
require 'support/models/empty_cop'
require 'support/controllers/dummy_controller'

RSpec.describe DummyController, '#authorizy', type: :controller do
  let!(:user) { User.new }

  context 'when cop responds to the controller name' do
    context 'when method resturns false' do
      it 'denies the access' do
        config_mock(cop: AuthorizyCop, current_user: user) do
          get :action, params: { access: false }
        end

        expect(response).to redirect_to('/')
      end
    end

    context 'when method resturns true' do
      it 'denies the access' do
        config_mock(cop: AuthorizyCop, current_user: user) do
          get :action, params: { access: true }
        end

        expect(response.body).to eq('{"message":"authorized"}')
      end
    end
  end

  context 'when cop does not respond to the controller name' do
    it 'denies the access' do
      config_mock(cop: EmptyCop, current_user: user) do
        get :action
      end

      expect(response).to redirect_to('/')
    end
  end
end
