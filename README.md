# Simple Calendly APIs client

[![Test](https://github.com/koshilife/calendly-api-ruby-client/workflows/Test/badge.svg)](https://github.com/koshilife/calendly-api-ruby-client/actions?query=workflow%3ATest)
[![codecov](https://codecov.io/gh/koshilife/calendly-api-ruby-client/branch/master/graph/badge.svg)](https://codecov.io/gh/koshilife/calendly-api-ruby-client)
[![Gem Version](https://badge.fury.io/rb/calendly.svg)](http://badge.fury.io/rb/calendly)
[![license](https://img.shields.io/github/license/koshilife/calendly-api-ruby-client)](https://github.com/koshilife/calendly-api-ruby-client/blob/master/LICENSE.txt)

## About

These client libraries are created for [Calendly v2 APIs](https://calendly.stoplight.io/docs/gh/calendly/api-docs).

As of August 2020, Calendly v2 API is currently undergoing an upgrade.
This library is trying to follow and support for the upgrade.

As of now the supported statuses each Calendly API are as below.

## Supported statuses each Calendly API

- User
  - [x] Get basic information about a user
- EventType
  - [ ] Get Event Type (This endpoint hasn't been released yet.)
  - [ ] User Event Types
- Organization
  - [ ] Get Organization Invitation
  - [ ] Get Organization Invitations
  - [ ] Get Organization Membership
  - [ ] Get a list of Organization Memberships
  - [ ] Invite a person to Organization
  - [ ] Remove a User from an Organization
  - [ ] Revoke Organization Invitation
- Organization
  - [ ] Get Event
  - [ ] Get Invitee of an Event
  - [ ] Get List of Event Invitees
  - [ ] Get List of User Events
- Webhook V2
  - These endpoints havn't been released yet.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'calendly'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install calendly

## Usage

The APIs client needs access token.

```ruby
# set token by Calendly.configure methods.
Calendly.configure do |config|
  config.token            = '<ACCESS_TOKEN>'
  # follows are options. you can refresh access token if set it.
  config.client_id        = '<CLIENT_ID>'
  config.client_secret    = '<CLIENT_SECRET>'
  config.refresh_token    = '<REFRESH_ACCESS_TOKEN>'
  config.token_expires_at = '<ACCESS_TOKEN_EXPIRES_AT>'
end
client = Calendly::Client.new

# set token by Calendly::Client initializer.
client = Calendly::Client.new('<ACCESS_TOKEN>')
```

```ruby
# get a current user's information.
user = client.current_user
# => <Calendly::User:70295889934840 uuid:U123456789>
user.scheduling_url
# => "https://calendly.com/YOUR_SLUG"
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/koshilife/calendly-api-ruby-client). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Calendly Api Client project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/koshilife/calendly-api-ruby-client/blob/master/CODE_OF_CONDUCT.md).
