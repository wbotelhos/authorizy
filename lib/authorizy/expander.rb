# frozen_string_literal: true

module Authorizy
  class Expander
    def expand(permissions)
      return [] if permissions.blank?

      result = {}

      permissions.each do |permission|
        controller = permission[0].to_s
        action = permission[1].to_s

        result["#{controller}##{action}"] = [controller, action]

        if (items = controller_dependency(controller, action))
          items.each do |controller_item, action_item|
            result["#{controller_item}##{action_item}"] = [controller_item, action_item]
          end
        end

        actions = [default_aliases[action]].flatten.compact

        next if actions.blank?

        actions.each do |action_item|
          result["#{controller}##{action_item}"] = [controller, action_item.to_s]
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
