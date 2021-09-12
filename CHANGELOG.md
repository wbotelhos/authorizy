# v0.4.1

## Fixes

- `redirect_url` was receiving the `denied` context instead of the controller's context;

# v0.4.0

## Fixes

- Returns `403` status code, to represent recognized but not authorized, instead `401`;

## Features

- Added `denied` callback allowing a custom acess denied treatment;

# v0.3.0

## Features

- Added options `field` to customize how the authorizy field is fetched;

# v0.2.2

## Fixes

- When Cop returns anything different from `true` it is converted to `false`;

# v0.2.1

## Fixes

- Returns `401` status code when user has no authorization on a XHR request;

# v0.2.0

## Break Changes

- The permissions format now is:

```
{
  permissions: [
    ['controller', 'action'],
    ['controller2', 'action2'],
  ]
}
```

## Fixes

- Calls the `Authorizy::BaseCop#access?` as the first check intercepting all requests;

## Features

- Added RSpec matcher to make the test easier;

# v0.1.0

## Features

- Enables permission control via JSON data;
