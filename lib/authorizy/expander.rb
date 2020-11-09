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

        result["#{item['controller']}##{item['action']}"] = item

        if (items = controller_dependency(item))
          items.each { |data| result["#{data['controller']}##{data['action']}"] = data }
        end

        actions = [default_aliases[item['action'].to_s]].flatten.compact

        next if actions.blank?

        actions.each do |action|
          result["#{item['controller']}##{action}"] = {
            'action'     => action.to_s,
            'controller' => item['controller'].to_s
          }
        end
      end

      result.values
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

      items.map { |item| item.transform_values(&:to_s) }
    end
  end
end
