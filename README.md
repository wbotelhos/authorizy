# Authorizy

[![CI](https://github.com/wbotelhos/authorizy/workflows/CI/badge.svg)](https://github.com/wbotelhos/authorizy/actions)
[![Gem Version](https://badge.fury.io/rb/authorizy.svg)](https://badge.fury.io/rb/authorizy)
[![Maintainability](https://api.codeclimate.com/v1/badges/f312587b4f126bb13e85/maintainability)](https://codeclimate.com/github/wbotelhos/authorizy/maintainability)
[![Coverage](https://codecov.io/gh/wbotelhos/authorizy/branch/main/graph/badge.svg)](https://codecov.io/gh/wbotelhos/authorizy)
[![Sponsor](https://img.shields.io/badge/sponsor-%3C3-green)](https://www.patreon.com/wbotelhos)

A JSON based Authorization.

##### Why not [cancancan](https://github.com/CanCanCommunity/cancancan)?

I have been working with cancan/cancancan for years. Since the beginning with [database access](https://github.com/CanCanCommunity/cancancan/blob/develop/docs/Abilities-in-Database.md). After a while, I realised I built a couple of abstractions around `ability` class and suddenly migrated to JSON for better performance. As I need a full role admin I decided to start to extract this logic to a gem.

## Install

Add the following code on your `Gemfile` and run `bundle install`:

```ruby
gem 'authorizy'
```

Run the following task to create Authorizy migration and initialize.

```sh
rails g rating:install
```

Then execute the migration to adds the column `authorizy` to your `users` table.

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
    { controller: :user, action: :create },
    { controller: :user, action: :update },
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

### Dependencies

You can allow access to one or more controllers and actions based on your permissions. It'll consider not only the `action`, like [aliases](#aliases) but the controller either.

```ruby
Authorizy.configure do |config|
  config.dependencies = {
    payments: {
      index: [
        { controller: :users, action: :index },
        { controller: :enrollments, action: :index },
      ]
    }
  }
end
```

So now if a have the permission `payments#index` I'll receive more two permissions: `users#index` and `enrollments#index`.

### Cop

Sometimes we need to allow access in runtime because the permission will depend on the request data and/or some dynamic logic. For this you can create a *Cop* class, the inherit from `Authorizy::BaseCop`, to allow it based on logic. It works like a [Interceptor](https://en.wikipedia.org/wiki/Interceptor_pattern).

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

If your controller has a namespace, just use `__` to separate the modules name:

```ruby
class AuthorizyCop < Authorizy::BaseCop
  def admin__users
  end
end
```

### Current User

By default Authorizy fetch the current user from the variable `current_user`. You have a config, that receives the controller context, where you can change it:

```ruby
Authorizy.configure do |config|
  config.current_user -> (context) { context.current_person }
end
```

### Redirect URL

When authorization fails and the request is not a XHR request a redirect happens to `/` path. You can change it:

```ruby
Authorizy.configure do |config|
  config.redirect_url -> (context) { context.new_session_url }
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
