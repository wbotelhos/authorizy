# frozen_string_literal: true

require 'support/controllers/dummy_controller'
require 'support/models/authorizy_cop'

RSpec.describe DummyController, '#authorizy?', type: :controller do
  context 'when config returns no current user' do
    it 'returns false' do
      config_mock(current_user: nil) do
        expect(controller.helpers.authorizy?('controller', 'action')).to be(false)
      end
    end
  end

  context 'when config returns current user' do
    let!(:config) { Authorizy.config }
    let!(:user) { User.new }

    before { allow(Authorizy).to receive(:config).and_return(config) }

    context 'when authorizy returns false' do
      let!(:core) { instance_double(Authorizy::Core, access?: false) }
      let!(:parameters) { ActionController::Parameters.new(controller: 'controller', action: 'action') }

      it 'returns false' do
        allow(Authorizy::Core).to receive(:new)
          .with(user, parameters, session, cop: config.cop)
          .and_return(core)

        config_mock(current_user: user) do
          expect(controller.helpers.authorizy?('controller', 'action')).to be(false)
        end
      end
    end

    context 'when authorizy returns true' do
      let!(:core) { instance_double(Authorizy::Core, access?: true) }
      let!(:parameters) { ActionController::Parameters.new(controller: 'controller', action: 'action') }

      it 'returns true' do
        allow(Authorizy::Core).to receive(:new)
          .with(user, parameters, session, cop: config.cop)
          .and_return(core)

        config_mock(current_user: user) do
          expect(controller.helpers.authorizy?('controller', 'action')).to be(true)
        end
      end
    end

    describe ':custom_params' do
      let!(:core) { instance_double(Authorizy::Core, access?: true) }
      let!(:parameters) { ActionController::Parameters.new(controller: 'controller', action: 'action') }

      before { allow(Authorizy::Core).to receive(:new).and_return(core) }

      context 'when is provided' do
        let!(:custom_params) { { key: 'value' } }
        let!(:expected_params) { parameters.merge(custom_params) }

        it 'forwards to core' do
          config_mock(current_user: user) do
            controller.helpers.authorizy?('controller', 'action', custom_params:)

            expect(Authorizy::Core).to have_received(:new).with(user, expected_params, session, cop: config.cop)
          end
        end
      end

      context 'when is not provided' do
        let!(:custom_params) { {} }
        let!(:expected_params) { parameters.merge(custom_params) }

        it 'forwards to cop' do
          config_mock(cop: AuthorizyCop, current_user: user) do
            controller.helpers.authorizy?('controller', 'action', custom_params:)

            expect(Authorizy::Core).to have_received(:new).with(user, expected_params, session, cop: config.cop)
          end
        end
      end
    end
  end
end
