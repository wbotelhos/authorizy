# frozen_string_literal: true

module Authorizy
  class Expander
    def expand(permissions)
      return [] if permissions.blank?

      result = {}

      permissions.each do |permission|
        controller, action = permission[0].to_s, permission[1].to_s

        result["#{controller}##{action}"] = [controller, action]

        if (items = controller_dependency(controller, action))
          items.each { |c, a| result["#{c}##{a}"] = [c, a] }
        end

        actions = [default_aliases[action]].flatten.compact

        next if actions.blank?

        actions.each do |action|
          result["#{controller}##{action}"] = ['controller', action.to_s]
        end
      end

      result.values # TODO: garantir o uniq
    end

    private

    def aliases
      Authorizy.config.aliases.stringify_keys
    end

    def controller_dependency(controller, action)
      return if (actions = dependencies[controller]).blank?
      return if (permissions = actions[action]).blank?

      permissions.map { |c, a| [c.to_s, a.to_s] }
    end

    def default_aliases
      {
        'create' => 'new',
        'edit'   => 'update',
        'new'    => 'create',
        'update' => 'edit',
      }.merge(aliases)
    end

    def dependencies
      Authorizy.config.dependencies.deep_stringify_keys
    end
  end
end
