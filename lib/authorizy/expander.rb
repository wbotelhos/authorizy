# frozen_string_literal: true

module Authorizy
  class Expander
    def initialize(aliases, dependencies)
      @aliases      = aliases
      @dependencies = dependencies.stringify_keys
    end

    def expand(permissions)
      return [] if permissions.blank?

      result = permissions.dup

      permissions.each do |permission|
        item = permission.stringify_keys

        if (items = controller_dependency(item))
          result += items
        end

        action = [default_aliases[item['action'].to_s]].flatten.compact

        next if action.blank?

        action.each do |action|
          result << { action: action.to_s, controller: item['controller'].to_s }
        end
      end

      result
    end

    private

    def default_aliases
      {
        'create' => 'new',
        'edit'   => 'update',
        'new'    => 'create',
        'update' => 'edit',
      }.merge(@aliases)
    end

    def controller_dependency(item)
      return if (controller = @dependencies[item['controller'].to_s]).blank?
      return if (items = controller.stringify_keys[item['action'].to_s]).blank?

      items
    end
  end
end
