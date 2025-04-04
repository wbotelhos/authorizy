# frozen_string_literal: true

RSpec.describe Authorizy::Core, '#access?' do
  context 'when cop#access? returns true' do
    let!(:cop) { Struct.new(:access?).new(access?: true) }
    let!(:current_user) { User.new }
    let!(:params) { { action: 'any', controller: 'any' } }
    let!(:session) { {} }

    it 'is authorized based in the cop response' do
      expect(described_class.new(current_user, params, session, cop:).access?).to be(true)
    end
  end

  context 'when permissions is in the current user' do
    let!(:cop) { Struct.new(:access?).new(access?: false) }
    let!(:current_user) { User.new(authorizy: { permissions: [%w[controller create]] }) }
    let!(:params) { { controller: 'controller', action: 'create' } }
    let!(:session) { {} }

    it 'is authorized based on the user permissions' do
      expect(described_class.new(current_user, params, session, cop:).access?).to be(true)
    end
  end

  context 'when session has no permission nor the user' do
    let!(:cop) { Struct.new(:access?).new(access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { controller: 'match', action: 'create' } }
    let!(:session) { {} }

    it 'does not authorize' do
      expect(described_class.new(current_user, params, session, cop:).access?).to be(false)
    end
  end

  context 'when cop does not respond to controller' do
    let!(:cop) { instance_double(Authorizy::BaseCop, access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { action: 'create', controller: 'missing' } }
    let!(:session) { {} }

    it 'does not authorize via cop' do
      expect(described_class.new(current_user, params, session, cop:).access?).to be(false)
    end
  end

  context 'when cop responds to controller' do
    let!(:current_user) { User.new }
    let!(:params) { { controller: 'admin/controller', action: 'create' } }
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
        end.new(current_user, params, session)
      end

      it 'is not authorized by cop' do
        expect(described_class.new(current_user, params, session, cop:).access?).to be(false)
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
        end.new(current_user, params, session)
      end

      it 'is authorized by the cop' do
        expect(described_class.new(current_user, params, session, cop:).access?).to be(true)
      end
    end

    context 'when cop return nil' do
      let!(:cop) do
        Class.new(Authorizy::BaseCop) do
          def access?
            false
          end

          def admin__controller
            nil
          end
        end.new(current_user, params, session)
      end

      it 'is converted to false' do
        expect(described_class.new(current_user, params, session, cop:).access?).to be(false)
      end
    end

    context 'when cop return empty' do
      let!(:cop) do
        Class.new(Authorizy::BaseCop) do
          def access?
            false
          end

          def admin__controller
            ''
          end
        end.new(current_user, params, session)
      end

      it 'is converted to false' do
        expect(described_class.new(current_user, params, session, cop:).access?).to be(false)
      end
    end

    context 'when cop return nothing' do
      let!(:cop) do
        Class.new(Authorizy::BaseCop) do
          def access?
            false
          end

          def admin__controller; end
        end.new(current_user, params, session)
      end

      it 'is converted to false' do
        expect(described_class.new(current_user, params, session, cop:).access?).to be(false)
      end
    end

    context 'when cop return true as string' do
      let!(:cop) do
        Class.new(Authorizy::BaseCop) do
          def access?
            false
          end

          def admin__controller
            'true'
          end
        end.new(current_user, params, session)
      end

      it 'is converted to false' do
        expect(described_class.new(current_user, params, session, cop:).access?).to be(false)
      end
    end
  end

  context 'when user has the controller permission but not action' do
    let!(:cop) { instance_double(Authorizy::BaseCop, access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { controller: 'controller', action: 'action' } }
    let!(:session) { { permissions: [%w[controller miss]] } }

    it 'is not authorized' do
      expect(described_class.new(current_user, params, session, cop:).access?).to be(false)
    end
  end

  context 'when user has the action permission but not controller' do
    let!(:cop) { instance_double(Authorizy::BaseCop, access?: false) }
    let!(:current_user) { User.new }
    let!(:params) { { controller: 'controller', action: 'action' } }
    let!(:session) { { permissions: [%w[miss action]] } }

    it 'is not authorized' do
      expect(described_class.new(current_user, params, session, cop:).access?).to be(false)
    end
  end
end
