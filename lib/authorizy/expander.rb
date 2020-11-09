# frozen_string_literal: true

module Authorizy
  class Expander
    def initialize(aliases, dependencies)
      @aliases      = aliases.stringify_keys
      @dependencies = dependencies.deep_stringify_keys
    end

    def expand(permissions)
      return [] if permissions.blank?

      result = {}

      permissions.each do |permission|
        item = permission.stringify_keys.transform_values(&:to_s)

        result[key_for(item)] = item

        if (items = controller_dependency(item))
          items.each { |data| result[key_for(data)] = data }
        end

        actions = [default_aliases[item['action']]].flatten.compact

        next if actions.blank?

        actions.each do |action|
          result[key_for(item, action: action)] = { 'action' => action.to_s, 'controller' => item['controller'].to_s }
        end
      end

      result.values
    end

    private

    def controller_dependency(item)
      return if (actions = @dependencies[item['controller']]).blank?
      return if (permissions = actions[item['action']]).blank?

      permissions.map { |permission| permission.transform_values(&:to_s) }
    end

    def default_aliases
      {
        'create' => 'new',
        'edit'   => 'update',
        'new'    => 'create',
        'update' => 'edit',
      }.merge(@aliases)
    end

    def key_for(item, action: nil)
      "#{item['controller']}##{action || item['action']}"
    end
  end
end
