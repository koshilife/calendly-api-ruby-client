# 0.0.5.alpha

- support APIs
  - `GET /organization_memberships`
  - `GET /organization_memberships/{uuid}`
- rename fields
  - Invitee#event to Invitee#event_uri
  - Event#event_type to Invitee#event_type_uri

# 0.0.4.alpha

- support APIs
  - `GET /scheduled_events/{event_uuid}/invitees`
  - `GET /scheduled_events/{event_uuid}/invitees/{invitee_uuid}`

# 0.0.3.alpha

- support APIs
  - `GET /scheduled_events`
  - `GET /scheduled_events/{uuid}`

# 0.0.2.alpha

- support APIs
  - `GET /event_types`

# 0.0.1.alpha

- Initial release
- support APIs
  - `GET /users/{uuid}`
