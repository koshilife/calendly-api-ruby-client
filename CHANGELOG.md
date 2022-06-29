# CHANGELOG

## 0.11.1 - 2022-06-29

- specified dependencies:
  - oauth2: 1.x series (refs #53)
  - faraday: 1.x or 2.x seriese (refs #51)

## 0.11.0 - 2022-05-02

- supported a API `POST /scheduled_events/{uuid}/cancellation`. (#48)
  - changed files:
    - Client
      - (Add method) cancel_event
    - Event
      - (Add method) cancel
- improved CI to test by multiple Ruby versions.

## 0.10.0 - 2022-04-15

- supported a API `POST /data_compliance/deletion/invitees`. (#28)
  - changed files:
    - Client
      - (Add method) delete_invitee_data

## 0.9.0 - 2022-04-14

- supported no show APIs. (#45)
  - `GET /invitee_no_shows/{no_show_uuid}`
  - `POST /invitee_no_shows`
  - `DELETE /invitee_no_shows/{no_show_uuid}`
  - changed files:
    - Client
      - (Add method) invitee_no_show
      - (Add method) create_invitee_no_show
      - (Add method) delete_invitee_no_show
    - Invitee model
      - (Add field) no_show
      - (Add method) mark_no_show
      - (Add method) unmark_no_show
    - (New) InviteeNoShow model
- To simplify `require` statements, changed `Model::ASSOCIATION` constant to class methods and removed unused lines.

## 0.8.3 - 2022-03-08

- support for filtering Event Types by 'active' or 'inactive' status. (#43)

## 0.8.2 - 2022-02-26

- support cancellation field in the response of scheduled event endpoints. (#41)

## 0.8.1 - 2021-10-20

- support new UUID format like 'bbc4f475-6125-435a-b713-2d1634651e10'. (#38, thanks to jameswilliamiii)

## 0.8.0 - 2021-06-03

- used keyword arguments for optional parameters, to be friendly for programmer.
- changed methods are followings:
  - Client
    - event_types
    - event_types_by_user
    - scheduled_events
    - scheduled_events_by_user
    - event_invitees
    - memberships
    - memberships_by_user
    - invitations
    - webhooks
    - user_scope_webhooks
    - create_schedule_link
  - Event
    - invitees
    - invitees!
  - EventType
    - create_schedule_link
  - Organization
    - memberships
    - memberships!
    - invitations
    - invitations!
    - event_types
    - event_types!
    - scheduled_events
    - scheduled_events!
    - webhooks
    - webhooks!
  - OrganizationMembership
    - user_scope_webhooks
    - user_scope_webhooks!
  - User
    - event_types
    - scheduled_events
    - webhooks
    - webhooks!

## 0.7.0 - 2021-06-03

- supported a signing key parameter when creating webhooks. (#33, thanks to ismael-texidor)
- changed `user_uri` argument to keyword argument on Client#create_webhook.

## 0.6.0 - 2021-05-30

- supported new features until April 2021. (#29)
  - Client
    - (Change) support organization options in `event_types` api.
    - (Rename) `event_types` to `event_types_by_user`
  - User model
    - (Add field) current_organization
    - (Add method) webhooks
    - (Add method) webhooks!
    - (Add method) create_webhook
  - Organization model
    - (Add method) event_types
    - (Add method) event_types!
  - Event model
    - (Remove field) invitees_counter_total
    - (Remove field) invitees_counter_active
    - (Remove field) invitees_counter_limit
    - (Add field) invitees_counter
    - (Add field) event_memberships
    - (Add field) event_guests
  - EventType model
    - (Remove field) owner_uuid
    - (Remove field) owner_uri
    - (Remove field) owner_name
    - (Add field) profile
    - (Add field) secret
    - (Add field) custom_questions
    - (Add method) owner_user
    - (Add method) owner_team
  - Invitee model
    - (Add field) first_name
    - (Add field) last_name
    - (Add field) cancellation
    - (Add field) payment
- fixed debug log encoding error. (#30)
- improved inspect method to be more readable in CLI.

## 0.5.2 - 2020-12-13

- started to support a API
  - `POST /scheduling_links`

## 0.5.1 - 2020-12-13

- added method EventType#fetch

## 0.5.0 - 2020-12-13

- changed Calendly::Client#scheduled_events behavior (refs #21)
  - previous version:
    - getting events belonging to a specific USER
  - current version:
    - getting all events belonging to a specific ORGANIZATION
- added Calendly::Client#scheduled_events_by_user method instead_of the before behavior

## 0.4.2 - 2020-11-26

- added new following fields to Invitee model (refs #21)
  - :rescheduled
  - :old_invitee
  - :new_invitee
  - :cancel_url
  - :reschedule_url

## 0.4.1 - 2020-11-22

- started to support a API
  - `GET /event_types/{uuid}`

## 0.4.0 - 2020-11-21

- fixed a changes for Location fields such as `kind` to `type`. (refs #18)

## 0.3.0 - 2020-11-18

- removed zeitwerk dependency. (refs #16)

## 0.2.0 - 2020-09-18

- added caching features in object when fetching data. (refs #14)

## 0.1.3 - 2020-09-17

- support webhook APIs (refs #9)
  - `GET /webhook_subscriptions`
  - `GET /webhook_subscriptions/{webhook_uuid}`
  - `POST /webhook_subscriptions`
  - `DELETE /webhook_subscriptions/{webhook_uuid}`

## 0.1.2 - 2020-09-03

- fixed rubocop warnings.

## 0.1.1 - 2020-08-27

- added tests to make coverage 100%.

## 0.1.0 - 2020-08-25

- defined methods to access associated resources with each model.
- renamed methods:
  - `Calendly::Client#events` to `Calendly::Client#scheduled_events`

## 0.0.7.alpha - 2020-08-23

- started to support APIs
  - `POST /organizations/{uuid}/invitations`
  - `DELETE /organizations/{org_uuid}/invitations/{invitation_uuid}`
  - `DELETE /organization_memberships/{uuid}`

## 0.0.6.alpha - 2020-08-22

- started to support APIs
  - `GET /organizations/{uuid}/invitations`
  - `GET /organizations/{organization_uuid}/invitations/{invitation_uuid}`

## 0.0.5.alpha - 2020-08-22

- started to support APIs
  - `GET /organization_memberships`
  - `GET /organization_memberships/{uuid}`
- renamed fields
  - Invitee#event to Invitee#event_uri
  - Event#event_type to Event#event_type_uri

## 0.0.4.alpha - 2020-08-22

- started to support APIs
  - `GET /scheduled_events/{event_uuid}/invitees`
  - `GET /scheduled_events/{event_uuid}/invitees/{invitee_uuid}`

## 0.0.3.alpha - 2020-08-19

- started to support APIs
  - `GET /scheduled_events`
  - `GET /scheduled_events/{uuid}`

## 0.0.2.alpha - 2020-08-12

- started to support APIs
  - `GET /event_types`

## 0.0.1.alpha - 2020-08-09

- Initial release
- started to support a API
  - `GET /users/{uuid}`
