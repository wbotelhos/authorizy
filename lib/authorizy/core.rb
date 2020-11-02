# frozen_string_literal: true

module Authorizy
  class Core
    def initialize(current_user, params, session, controller: params['controller'], action: params['action'], aliases: {}, dependencies: {})
      @action       = action.to_s
      @aliases      = aliases
      @controller   = controller.to_s
      @current_user = current_user
      @dependencies = dependencies
      @params       = params
      @session      = session
    end

    def access?
      return false if @current_user.blank?

      released = cop.public_send(cop_controller) if cop.respond_to?(cop_controller)

      return true if released
      return false if permissions.blank?

      permissions.any? do |item|
        data = item.stringify_keys

        data['controller'].to_s == @controller && data['action'].to_s == @action
      end
    end

    private

    attr_reader :params, :session

    def actions
      {
        'create' => 'new',
        'edit'   => 'update',
        'new'    => 'create',
        'update' => 'edit',
      }.merge(@aliases)
    end

    def cop
      Authorizy.config.cop.new(@current_user, @params, @session, @controller, @action)
    end

    def cop_controller
      @controller.sub('/', '__')
    end

    def dependencies
      @dependencies.stringify_keys
    end

    def expand(permissions)
      return [] if permissions.blank?

      all_permissions = []
      all_permissions += permissions

      permissions.each do |permission|
        item = permission.stringify_keys

        matched_controller = dependencies[item['controller'].to_s]

        if matched_controller.present?
          items = matched_controller.stringify_keys[item['action'].to_s]

          all_permissions += items if items.present?
        end

        matched_action = [actions[item['action'].to_s]].flatten.compact

        next if matched_action.blank?

        matched_action.each do |action|
          all_permissions << { action: action.to_s, controller: item['controller'].to_s }
        end
      end

      all_permissions
    end

    def permissions
      items = [session[:permissions]].flatten.compact.presence || @current_user.authorizy.try(:[], 'permissions')

      expand(items)
    end
  end
end
