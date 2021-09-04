# frozen_string_literal: true

require 'support/controllers/dummy_controller'

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
      let!(:core) { instance_double('Authorizy::Core', access?: false) }
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
      let!(:core) { instance_double('Authorizy::Core', access?: true) }
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
  end
end
