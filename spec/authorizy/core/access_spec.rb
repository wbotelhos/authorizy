# frozen_string_literal: true

RSpec.describe Authorizy::Core, '#access?' do
  context 'when cop#access? returns true' do
    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'any', 'controller' => 'any' } }
    let!(:session) { {} }

    let!(:cop) { instance_double('Authorizy::BaseCop', access?: true) }

    it 'uses the session value' do
      allow(Authorizy::BaseCop).to receive(:new)
        .with(current_user, params, session, 'any', 'any')
        .and_return(cop)

      expect(described_class.new(current_user, params, session).access?).to be(true)
    end
  end

  context 'when permissions is in session as string' do
    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'create', 'controller' => 'controller' } }
    let!(:session) { { 'permissions' => [{ 'action' => 'create', 'controller' => 'controller' }] } }

    it 'uses the session value' do
      expect(described_class.new(current_user, params, session).access?).to be(true)
    end
  end

  context 'when permissions is in current user' do
    subject(:authorizy) { described_class.new(current_user, params, session) }

    let!(:current_user) { User.new(authorizy: { permissions: [{ action: 'create', controller: 'match' }] }) }
    let!(:params) { { 'action' => 'create', 'controller' => 'match' } }
    let!(:session) { {} }

    it 'uses the session value' do
      expect(authorizy.access?).to be(true)
    end
  end

  context 'when session has no permission nor the user' do
    subject(:authorizy) { described_class.new(current_user, params, session) }

    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'create', 'controller' => 'match' } }
    let!(:session) { {} }

    it { expect(authorizy.access?).to be(false) }
  end

  context 'when cop does not respond to controller' do
    subject(:authorizy) { described_class.new(current_user, params, session) }

    let!(:cop) { instance_double('Authorizy::BaseCop', access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'create', 'controller' => 'missing' } }
    let!(:session) { {} }

    before do
      allow(Authorizy::BaseCop).to receive(:new)
        .with(current_user, params, session, 'missing', 'create')
        .and_return(cop)

      allow(cop).to receive(:respond_to?).with('missing').and_return(false)
    end

    it 'does not authorize via cop' do
      expect(authorizy.access?).to be(false)
    end
  end

  context 'when cop responds to controller' do
    subject(:authorizy) { described_class.new(current_user, params, session) }

    let!(:cop) { instance_double('Authorizy::BaseCop', access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'create', 'controller' => 'match' } }
    let!(:session) { {} }

    before do
      allow(Authorizy::BaseCop).to receive(:new)
        .with(current_user, params, session, 'match', 'create')
        .and_return(cop)

      allow(cop).to receive(:respond_to?).with('match').and_return(true)
    end

    context 'when cop does not release the access' do
      it 'continues trying via session and so user permissions' do
        allow(cop).to receive(:public_send).with('match').and_return(false)

        expect(authorizy.access?).to be(false)
      end
    end

    context 'when cop releases the access' do
      it 'skips session and user permission returning true to the access' do
        allow(cop).to receive(:public_send).with('match').and_return(true)

        expect(authorizy.access?).to be(true)
      end
    end
  end

  context 'when controller is given' do
    subject(:authorizy) { described_class.new(current_user, params, session, controller: 'controller') }

    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'action', 'controller' => 'ignored' } }
    let!(:session) { { 'permissions' => [{ 'action' => 'action', 'controller' => 'controller' }] } }

    it 'uses the given controller over the one on params' do
      expect(authorizy.access?).to be(true)
    end
  end

  context 'when action is given' do
    subject(:authorizy) { described_class.new(current_user, params, session, action: 'action') }

    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'ignored', 'controller' => 'controller' } }
    let!(:session) { { 'permissions' => [{ 'action' => 'action', 'controller' => 'controller' }] } }

    it 'uses the given action over the one on params' do
      expect(authorizy.access?).to be(true)
    end
  end

  context 'when user has the controller permission but not action' do
    subject(:authorizy) { described_class.new(current_user, params, session) }

    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'action', 'controller' => 'controller' } }
    let!(:session) { { 'permissions' => [{ 'action' => 'miss', 'controller' => 'controller' }] } }

    it 'cannot access' do
      expect(authorizy.access?).to be(false)
    end
  end

  context 'when user has the action permission but not controller' do
    subject(:authorizy) { described_class.new(current_user, params, session) }

    let!(:current_user) { User.new }
    let!(:params) { { 'action' => 'action', 'controller' => 'controller' } }
    let!(:session) { { 'permissions' => [{ 'action' => 'create', 'controller' => 'miss' }] } }

    it 'cannot access' do
      expect(authorizy.access?).to be(false)
    end
  end
end
