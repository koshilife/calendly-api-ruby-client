# CHANGELOG

## 0.6.0

- supported to new features until April 2021. (#29)
  - Client
    - (Change) support organization options in `event_types` api.
    - (Rename) `event_types` to `event_types_by_user`
  - User model
    - (Add field) current_organization
    - (Add method) webhooks
    - (Add method) webhooks!
    - (Add method) create_webhook
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

## 0.5.2

- started to support a API
  - `POST /scheduling_links`

## 0.5.1

- added method EventType#fetch

## 0.5.0

- changed Calendly::Client#scheduled_events behavior (refs #21)
  - previous version:
    - getting events belonging to a specific USER
  - current version:
    - getting all events belonging to a specific ORGANIZATION
- added Calendly::Client#scheduled_events_by_user method instead_of the before behavior

## 0.4.2

- added new following fields to Invitee model (refs #21)
  - :rescheduled
  - :old_invitee
  - :new_invitee
  - :cancel_url
  - :reschedule_url

## 0.4.1

- started to support a API
  - `GET /event_types/{uuid}`

## 0.4.0

- fixed a changes for Location fields such as `kind` to `type`. (refs #18)

## 0.3.0

- removed zeitwerk dependency. (refs #16)

## 0.2.0

- added caching features in object when fetching data. (refs #14)

## 0.1.3

- support webhook APIs (refs #9)
  - `GET /webhook_subscriptions`
  - `GET /webhook_subscriptions/{webhook_uuid}`
  - `POST /webhook_subscriptions`
  - `DELETE /webhook_subscriptions/{webhook_uuid}`

## 0.1.2

- fixed rubocop warnings.

## 0.1.1

- added tests to make coverage 100%.

## 0.1.0

- defined methods to access associated resources with each model.
- renamed methods:
  - `Calendly::Client#events` to `Calendly::Client#scheduled_events`

## 0.0.7.alpha

- started to support APIs
  - `POST /organizations/{uuid}/invitations`
  - `DELETE /organizations/{org_uuid}/invitations/{invitation_uuid}`
  - `DELETE /organization_memberships/{uuid}`

## 0.0.6.alpha

- started to support APIs
  - `GET /organizations/{uuid}/invitations`
  - `GET /organizations/{organization_uuid}/invitations/{invitation_uuid}`

## 0.0.5.alpha

- started to support APIs
  - `GET /organization_memberships`
  - `GET /organization_memberships/{uuid}`
- renamed fields
  - Invitee#event to Invitee#event_uri
  - Event#event_type to Event#event_type_uri

## 0.0.4.alpha

- started to support APIs
  - `GET /scheduled_events/{event_uuid}/invitees`
  - `GET /scheduled_events/{event_uuid}/invitees/{invitee_uuid}`

## 0.0.3.alpha

- started to support APIs
  - `GET /scheduled_events`
  - `GET /scheduled_events/{uuid}`

## 0.0.2.alpha

- started to support APIs
  - `GET /event_types`

## 0.0.1.alpha

- Initial release
- started to support a API
  - `GET /users/{uuid}`
