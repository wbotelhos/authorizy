# frozen_string_literal: true

RSpec.describe Authorizy::Core, '#access?' do
  context 'when cop#access? returns true' do
    let!(:cop) { OpenStruct.new(access?: true) }
    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'any', 'controller' => 'any' } }
    let!(:session) { {} }

    it 'is authorized based in the cop response' do
      expect(described_class.new(current_user, params, session, cop: cop).access?).to be(true)
    end
  end

  context 'when permissions is in session as string' do
    let!(:cop) { OpenStruct.new(access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { 'controller' => 'controller', 'action' => 'action' } }
    let!(:session) { { 'permissions' => [['controller', 'action']] } }

    it 'is authorized based in session permissions' do
      expect(described_class.new(current_user, params, session, cop: cop).access?).to be(true)
    end
  end

  context 'when permissions is in the current user' do
    let!(:cop) { OpenStruct.new(access?: false) }
    let!(:current_user) { User.new(authorizy: { permissions: [['controller', 'create']] }) }
    let!(:params) { { 'controller' => 'controller', 'action' => 'create' } }
    let!(:session) { {} }

    it 'is authorized based on the user permissions' do
      expect(described_class.new(current_user, params, session, cop: cop).access?).to be(true)
    end
  end

  context 'when session has no permission nor the user' do
    let!(:cop) { OpenStruct.new(access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { 'controller' => 'match', 'action' => 'create' } }
    let!(:session) { {} }

    it 'does not authorize' do
      expect(described_class.new(current_user, params, session, cop: cop).access?).to be(false)
    end
  end

  context 'when cop does not respond to controller' do
    let!(:cop) { instance_double('Authorizy::BaseCop', access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'create', 'controller' => 'missing' } }
    let!(:session) { {} }

    it 'does not authorize via cop' do
      expect(described_class.new(current_user, params, session, cop: cop).access?).to be(false)
    end
  end

  context 'when cop responds to controller' do
    let!(:current_user) { User.new }
    let!(:params) { { 'controller' => 'admin/controller', 'action' => 'create' } }
    let!(:session) { {} }

    context 'when cop does not release the access' do
      let!(:cop) do
        Class.new(Authorizy::BaseCop) do
          def access?
            false
          end

          def admin__controller
            false
          end
        end.new(current_user, params, session, params['controller'], params['action'])
      end

      it 'is not authorized by cop' do
        expect(described_class.new(current_user, params, session, cop: cop).access?).to be(false)
      end
    end

    context 'when cop releases the access' do
      let!(:cop) do
        Class.new(Authorizy::BaseCop) do
          def access?
            false
          end

          def admin__controller
            true
          end
        end.new(current_user, params, session, params['controller'], params['action'])
      end

      it 'is authorized by the cop' do
        expect(described_class.new(current_user, params, session, cop: cop).access?).to be(true)
      end
    end
  end

  context 'when controller is given' do
    let!(:cop) { instance_double('Authorizy::BaseCop', access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'action' } }
    let!(:session) { { 'permissions' => [['controller', 'action']] } }

    it 'uses the given controller over the one on params' do
      expect(described_class.new(current_user, params, session, controller: 'controller', cop: cop).access?).to be(true)
    end
  end

  context 'when action is given' do
    let!(:cop) { instance_double('Authorizy::BaseCop', access?: false) }

    let!(:current_user) { User.new }
    let!(:params) { { 'controller' => 'controller' } }
    let!(:session) { { 'permissions' => [['controller', 'action']] } }

    it 'uses the given action over the one on params' do
      expect(described_class.new(current_user, params, session, action: 'action', cop: cop).access?).to be(true)
    end
  end

  context 'when user has the controller permission but not action' do
    let!(:cop) { instance_double('Authorizy::BaseCop', access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { 'controller' => 'controller', 'action' => 'action' } }
    let!(:session) { { 'permissions' => [['controller', 'miss']] } }

    it 'is not authorized' do
      expect(described_class.new(current_user, params, session, cop: cop).access?).to be(false)
    end
  end

  context 'when user has the action permission but not controller' do
    let!(:cop) { instance_double('Authorizy::BaseCop', access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { 'controller' => 'controller', 'action' => 'action' } }
    let!(:session) { { 'permissions' => [['miss', 'action']] } }

    it 'is not authorized' do
      expect(described_class.new(current_user, params, session, cop: cop).access?).to be(false)
    end
  end
end
