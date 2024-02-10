# Authorizy

[![CI](https://github.com/wbotelhos/authorizy/workflows/CI/badge.svg)](https://github.com/wbotelhos/authorizy/actions)
[![Gem Version](https://badge.fury.io/rb/authorizy.svg)](https://badge.fury.io/rb/authorizy)
[![Maintainability](https://api.codeclimate.com/v1/badges/f312587b4f126bb13e85/maintainability)](https://codeclimate.com/github/wbotelhos/authorizy/maintainability)
[![Coverage](https://codecov.io/gh/wbotelhos/authorizy/branch/main/graph/badge.svg)](https://codecov.io/gh/wbotelhos/authorizy)
[![Sponsor](https://img.shields.io/badge/sponsor-%3C3-green)](https://github.com/sponsors/wbotelhos)

A JSON based Authorization.

## Install

Add the following code on your `Gemfile` and run `bundle install`:

```ruby
gem 'authorizy'
```

Run the following task to create Authorizy migration and initialize.

```sh
rails g authorizy:install
```

Then execute the migration to add the column `authorizy` to your `users` table.

```sh
rake db:migrate
```

## Usage

```ruby
class ApplicationController < ActionController::Base
  include Authorizy::Extension
end
```

Add the `authorizy` filter on the controller you want enables authorization.

```ruby
class UserController < ApplicationController
  before_action :authorizy
end
```

## JSON

The column `authorizy` is a JSON column that has a key called `permission` with a list of permissions identified by the controller and action name which the user can access.

```ruby
{
  permissions: [
    [users, :create],
    [users, :update],
  }
}
```

## Configuration

You can change the default configuration.

### Aliases

Alias is an action that maps another action. We have some defaults.

|Action|alias |
|------|------|
|create|new   |
|edit  |update|
|new   |create|
|update|edit  |

You can add more alias, for example, all permissions for action `index` will allow access to action `gridy` of the same controller. So `users#index` will allow `users#gridy` too.

```ruby
Authorizy.configure do |config|
  config.aliases = { index: :gridy }
end
```

### Cop

Sometimes we need to allow access in runtime because the permission will depend on the request data and/or some dynamic logic. For this you can create a *Cop* class, that inherits from `Authorizy::BaseCop`, to allow it based on logic. It works like a [Interceptor](https://en.wikipedia.org/wiki/Interceptor_pattern).

First, you need to configure your cop:

```ruby
Authorizy.configure do |config|
  config.cop = AuthorizyCop
end
```

Now creates the cop class. The following example will intercept all access to the controller `users_controller`:

```ruby
class AuthorizyCop < Authorizy::BaseCop
  def users
    return false if action           == 'create'
    return false if controller       == 'users'
    return true  if current_user     == User.find_by(admin: true)
    return true  if params[:allow]   == 'true'
    return true  if session[:logged] == 'true'
  end
end
```

As you can see, you have access to a couple of variables: `action`, `controller`, `current_user`, `params`, and `session`.
When you return `false`, the authorization will be denied, when you return `true` your access will be allowed.

If your controller has a namespace, just use `__` to separate the modules name:

```ruby
class AuthorizyCop < Authorizy::BaseCop
  def admin__users
  end
end
```

If you want to intercept all request as the first Authorizy check, you can override the `access?` method:

```ruby
class AuthorizyCop < Authorizy::BaseCop
  def access?
    return true if current_user.admin?
  end
end
```

### Current User

By default Authorizy fetch the current user from the variable `current_user`. You have a config, that receives the controller context, where you can change it:

```ruby
Authorizy.configure do |config|
  config.current_user = -> (context) { context.current_person }
end
```

### Denied

When some access is denied, by default, Authorizy checks if it is a XHR request or not and then redirect or serializes a message with status code `403`. You can rescue it by yourself:

```ruby
config.denied = ->(context) { context.redirect_to(subscription_path, info: 'Subscription expired!') }
```

### Dependencies

You can allow access to one or more controllers and actions based on your permissions. It'll consider not only the `action`, like [aliases](#aliases) but the controller either.

```ruby
Authorizy.configure do |config|
  config.dependencies = {
    payments: {
      index: [
        ['system/users', :index],
        ['system/enrollments', :index],
      ]
    }
  }
end
```

So now if a have the permission `payments#index` I'll receive more two permissions: `users#index` and `enrollments#index`.

### Field

By default the permissions are located inside the field called `authorizy` in the configured `current_user`. You can change how this field is fetched:

```ruby
Authorizy.configure do |config|
  @field = ->(current_user) { current_user.profile.authorizy }
end
```

### Redirect URL

When authorization fails and the request is not a XHR request a redirect happens to `/` path. You can change it:

```ruby
Authorizy.configure do |config|
  config.redirect_url = -> (context) { context.new_session_url }
end
```

# Helper

You can use `authorizy?` method to check if `current_user` has access to some `controller` and `action`.

Using on controller:

```ruby
class UserController < ApplicationController
  before_action :assign_events, if: -> { authorizy?('system/events', 'index') }

  def assign_events
  end
end
```

Using on view:

```ruby
<% if authorizy?(:users, :create) %>
  <a href="/users/new">New User</a>
<% end %>
```

Using on jBuilder view:

```ruby
json.create_link new_users_url if authorizy?(:users, :create)
```

# Specs

To test some routes you'll need to give or not permission to the user, for that you have to ways, where the first is give permission to the user via session:

```ruby
before do
  sign_in(current_user)

  session[:permissions] = [[:users, :create]]
end
```

Or you can put the permission directly in the current user:

```ruby
before do
  sign_in(current_user)

  current_user.update(permissions: [[:users, :create]])
end
```

## Checks

We have a couple of check, here is the order:

1. `Authorizy::BaseCop#access?`;
2. `session[:permissions]`;
3. `current_user.authorizy['permissions']`;
4. `Authorizy::BaseCop#controller_name`;

## Performance

If you have few permissions, you can save the permissions in the session and avoid hit database many times, but if you have a couple of them, maybe it's a good idea save it in some place like [Redis](https://redis.io).

## Management

It's a good idea you keep your permissions in the database, so the customer can change it dynamic. You can load all permissions when the user is logged and cache it later. For cache expiration, you can trigger a refresh everytime that the permissions change.

## Database Structure

Inside database you can use the following relation to dynamicly change your permissions:

```ruby
plans -> plans_permissions <- permissions
                |
                v
        role_plan_permissions
                ^
                |
              roles
```

## RSpec

You can test you app passing through all authorizy layers:

```ruby
user = User.create!(permission: { permissions: [[:users, :create]] })

expect(user).to be_authorized(:users, :create)
```

Or make sure the user does not have access:

```ruby
user = User.create!(permission: {})

expect(user).not_to be_authorized(:users, :create)
```
