# frozen_string_literal: true

require 'support/controllers/dummy_controller'

RSpec.describe DummyController, '#authorizy', type: :controller do
  let!(:aliases) { { index: 'gridy' } }
  let!(:dependencies) { { controller: { index: [{ action: :show, controller: :controller }] } } }
  let!(:parameters) { ActionController::Parameters.new(key: 'value', controller: 'dummy', action: 'action') }
  let!(:user) { User.create! }

  Rails.application.routes.draw { get :action, to: 'dummy#action' }

  context 'with default configuration' do
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

  context 'with custom configuration' do
    let!(:original_config) do
      {
        aliases:      Authorizy.config.aliases,
        current_user: Authorizy.config.current_user,
        dependencies: Authorizy.config.dependencies,
        redirect_url: Authorizy.config.redirect_url,
      }
    end

    before do
      Authorizy.configure do |config|
        config.aliases      = aliases
        config.current_user = -> (_context) { user }
        config.dependencies = dependencies
        config.redirect_url = -> (_context) { '/login' }
      end
    end

    after do
      Authorizy.configure do |config|
        config.aliases      = original_config[:aliases]
        config.current_user = original_config[:current_user]
        config.dependencies = original_config[:dependencies]
        config.redirect_url = original_config[:redirect_url]
      end
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

          expect(response.body).to   eq('{"message":"Action denied for dummy#action"}')
          expect(response.status).to be(422)
        end
      end

      context 'when is a html request' do
        it 'receives the default values and do not denied the access' do
          get :action, params: { key: 'value' }

          expect(response).to redirect_to '/login'

          # expect(flash[:info]).to eq('Action denied for dummy#action') # TODO: get flash message
        end
      end
    end
  end
end
