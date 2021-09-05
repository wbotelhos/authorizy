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
