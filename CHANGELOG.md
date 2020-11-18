# CHANGELOG

## 0.3.0

- remove zeitwerk dependency. (refs #16)

## 0.2.0

- save fetched data in cache. (refs #14)

## 0.1.3

- support webhook APIs (refs #9)
  - `GET /webhook_subscriptions`
  - `GET /webhook_subscriptions/{webhook_uuid}`
  - `POST /webhook_subscriptions`
  - `DELETE /webhook_subscriptions/{webhook_uuid}`

## 0.1.2

- fix rubocop warnings.

## 0.1.1

- add tests to make coverage 100%.

## 0.1.0

- define methods to access associated resources with each model.
- rename methods:
  - `Calendly::Client#events` to `Calendly::Client#scheduled_events`

## 0.0.7.alpha

- support APIs
  - `POST /organizations/{uuid}/invitations`
  - `DELETE /organizations/{org_uuid}/invitations/{invitation_uuid}`
  - `DELETE /organization_memberships/{uuid}`

## 0.0.6.alpha

- support APIs
  - `GET /organizations/{uuid}/invitations`
  - `GET /organizations/{organization_uuid}/invitations/{invitation_uuid}`

## 0.0.5.alpha

- support APIs
  - `GET /organization_memberships`
  - `GET /organization_memberships/{uuid}`
- rename fields
  - Invitee#event to Invitee#event_uri
  - Event#event_type to Event#event_type_uri

## 0.0.4.alpha

- support APIs
  - `GET /scheduled_events/{event_uuid}/invitees`
  - `GET /scheduled_events/{event_uuid}/invitees/{invitee_uuid}`

## 0.0.3.alpha

- support APIs
  - `GET /scheduled_events`
  - `GET /scheduled_events/{uuid}`

## 0.0.2.alpha

- support APIs
  - `GET /event_types`

## 0.0.1.alpha

- Initial release
- support APIs
  - `GET /users/{uuid}`
