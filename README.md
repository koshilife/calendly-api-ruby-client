# Calendly APIs client

[![Test](https://github.com/koshilife/calendly-api-ruby-client/workflows/Test/badge.svg)](https://github.com/koshilife/calendly-api-ruby-client/actions?query=workflow%3ATest)
[![codecov](https://codecov.io/gh/koshilife/calendly-api-ruby-client/branch/master/graph/badge.svg)](https://codecov.io/gh/koshilife/calendly-api-ruby-client)
[![Gem Version](https://badge.fury.io/rb/calendly.svg)](http://badge.fury.io/rb/calendly)
[![license](https://img.shields.io/github/license/koshilife/calendly-api-ruby-client)](https://github.com/koshilife/calendly-api-ruby-client/blob/master/LICENSE.txt)

These client libraries are created for [Calendly v2 APIs](https://calendly.stoplight.io/).

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

### Basic

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
#
# get a current user's information.
#
me = client.me
# => #<Calendly::User uuid="U001", name="Foo Bar", slug="foobar", email="foobar@example.com", ..>

me.scheduling_url
# => "https://calendly.com/foobar"

#
# get all event types
#
event_types = me.event_types
# => [#<Calendly::EventType uuid="ET001", name="15 Minute Meeting", type="StandardEventType", slug="15min", active=true, kind="solo", scheduling_url="https://calendly.com/foobar/15min", ..>, #<Calendly::EventType uuid="ET002", name="30 Minute Meeting", type="StandardEventType", slug="30min", active=true, kind="solo", scheduling_url="https://calendly.com/foobar/30min", ..>]

event_type = event_types.first
event_type.scheduling_url
# => "https://calendly.com/foobar/15min"

#
# get available times for the event type
#
available_times = event_type.available_times
available_times.map(&:start_time)
# => [2022-08-04 01:00:00 UTC, 2022-08-04 01:15:00 UTC, 2022-08-04 01:30:00 UTC]

# you can specify the date range
event_type.available_times(start_time: '2022-08-04T10:30:00Z', end_time: '2022-08-05T10:30:00Z')

#
# get scheduled events
#
events = me.scheduled_events
# => => [#<Calendly::Event uuid="EV001", name="FooBar Meeting", status="active", ..>, #<Calendly::Event uuid="EV002", name="Team Meeting", status="active", ..>]
ev = events.first
ev.name
# => "FooBar Meeting"
ev.start_time
# => 2020-07-22 01:30:00 UTC
ev.end_time
# => 2020-07-22 02:00:00 UTC

#
# get a current organization's information
#
org = me.current_organization
# => #<Calendly::Organization uuid="ORG001", ..>
all_members = org.memberships
# => [#<Calendly::OrganizationMembership uuid="MEM001", role="owner", ..>, #<Calendly::OrganizationMembership uuid="MEM002", role="user", ..>]

#
# create new invitation and send invitation email
#
invitation = org.create_invitation('foobar@example.com')
# => #<Calendly::OrganizationInvitation uuid="INV001", status="pending", email="foobar@example.com", ..>

# cancel the invitation
invitation.delete
# => true
```

### Webhook

The webhook usage is below.

```ruby
url = 'https://example.com/received_event'
subscribable_user_events = ['invitee.created', 'invitee.canceled']
subscribable_org_events = ['invitee.created', 'invitee.canceled', 'routing_form_submission.created']

#
# create a user scope webhook
#
me = client.me
user_webhook = me.create_webhook(url, subscribable_user_events)
# => #<Calendly::WebhookSubscription uuid="USER_WEBHOOK_001", state="active", scope="user", events=["invitee.created", "invitee.canceled"], callback_url="https://example.com/received_event", ..>

# list of user scope webhooks
me.webhooks
# => [#<Calendly::WebhookSubscription uuid="USER_WEBHOOK_001", state="active", scope="user", events=["invitee.created", "invitee.canceled"], callback_url="https://example.com/received_event", ..>]

# delete the webhook
user_webhook.delete
# => true

#
# create an organization scope webhook
#
org = client.me.current_organization
org_webhook = org.create_webhook(url, subscribable_org_events)
# => #<Calendly::WebhookSubscription uuid="ORG_WEBHOOK_001", state="active", scope="organization", events=["invitee.created", "invitee.canceled", "routing_form_submission.created"], callback_url="https://example.com/received_event", ..>

# list of organization scope webhooks
org.webhooks
# => [#<Calendly::WebhookSubscription uuid="ORG_WEBHOOK_001", state="active", scope="organization", events=["invitee.created", "invitee.canceled"], callback_url="https://example.com/received_event", ..>]

# delete the webhook
org_webhook.delete
# => true
```

### Logging

This library supports a configurable logger.

```ruby
# if the log level set :debug, you can get the request/response information.
Calendly.configuration.logger.level = :debug
invitation = org.create_invitation('foobar@example.com')
# D, [2020-08-10T10:48:15] DEBUG -- : Request POST https://api.calendly.com/organizations/ORG001/invitations params:, body:{:email=>"foobar@example.com"}
# D, [2020-08-10T10:48:16] DEBUG -- : Response status:201, body:{"resource":{"created_at":"2020-08-10T10:48:16.051159Z","email":"foobar@example.com","last_sent_at":"2020-08-10T10:48:16.096518Z","organization":"https://api.calendly.com/organizations/ORG001","status":"pending","updated_at":"2020-08-10T10:48:16.051159Z","uri":"https://api.calendly.com/organizations/ORG001/invitations/INV001"}}
```

More in-depth method documentation can be found at [RubyDoc.info](https://www.rubydoc.info/gems/calendly/).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/koshilife/calendly-api-ruby-client). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Calendly Api Client project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/koshilife/calendly-api-ruby-client/blob/master/CODE_OF_CONDUCT.md).
