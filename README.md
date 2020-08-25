# Calendly APIs client

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
  - [x] User Event Types
- Organization
  - [x] Get Organization Invitation
  - [x] Get Organization Invitations
  - [x] Get Organization Membership
  - [x] Get a list of Organization Memberships
  - [x] Invite a person to Organization
  - [x] Remove a User from an Organization
  - [x] Revoke Organization Invitation
- ScheduledEvent
  - [x] Get Event
  - [x] Get Invitee of an Event
  - [x] Get List of Event Invitees
  - [x] Get List of User Events
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
This client setup step is below.

```ruby
# set token by Calendly.configure methods.
Calendly.configure do |config|
  config.token            = '<ACCESS_TOKEN>'
  # follows are options. you can refresh access token if these are set.
  config.client_id        = '<CLIENT_ID>'
  config.client_secret    = '<CLIENT_SECRET>'
  config.refresh_token    = '<REFRESH_ACCESS_TOKEN>'
  config.token_expires_at = '<ACCESS_TOKEN_EXPIRES_AT>'
end
client = Calendly::Client.new


# set token by Calendly::Client initializer.
client = Calendly::Client.new '<ACCESS_TOKEN>'
```

This client basic usage is below.

```ruby
# get a current user's information.
me = client.me
# => <Calendly::User uuid:U001>
me.scheduling_url
# => "https://calendly.com/your_name"

# get all Event Types
event_types = me.event_types
# => [#<Calendly::EventType uuid:ET001>, #<Calendly::EventType uuid:ET002>, #<Calendly::EventType uuid:ET003>]
event_types.first.scheduling_url
# => "https://calendly.com/your_name/30min"

# get scheduled events
events = me.scheduled_events
# => => [#<Calendly::Event uuid:EV001>, #<Calendly::Event uuid:EV002>, #<Calendly::Event uuid:EV003>]
ev = events.first
ev.name
# => "FooBar Meeting"
ev.start_time
# => 2020-07-22 01:30:00 UTC
ev.end_time
# => 2020-07-22 02:00:00 UTC

# get organization information
own_member = me.organization_membership
# => #<Calendly::OrganizationMembership uuid:MEM001>
my_org = own_member.organization
all_members = my_org.memberships
# => [#<Calendly::OrganizationMembership uuid:MEM001>, #<Calendly::OrganizationMembership uuid:MEM002>]

# create new invitation and send invitation email
invitation = my_org.create_invitation('foobar@example.com')
# => #<Calendly::OrganizationInvitation uuid:INV001>
invitation.status
# => "pending"

# cancel the invitation
invitation.delete

# if the log level set :debug, you can get the request/response information.
Calendly.configuration.logger.level = :debug
invitation = my_org.create_invitation('foobar@example.com')
# D, [2020-08-10T10:48:15] DEBUG -- : Request POST https://api.calendly.com/organizations/ORG001/invitations params:, body:{:email=>"foobar@example.com"}
# D, [2020-08-10T10:48:16] DEBUG -- : Response status:201, body:{"resource":{"created_at":"2020-08-10T10:48:16.051159Z","email":"foobar@example.com","last_sent_at":"2020-08-10T10:48:16.096518Z","organization":"https://api.calendly.com/organizations/ORG001","status":"pending","updated_at":"2020-08-10T10:48:16.051159Z","uri":"https://api.calendly.com/organizations/ORG001/invitations/INV001"}}
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/koshilife/calendly-api-ruby-client). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Calendly Api Client project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/koshilife/calendly-api-ruby-client/blob/master/CODE_OF_CONDUCT.md).
