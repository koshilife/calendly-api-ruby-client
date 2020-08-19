# frozen_string_literal: true

require 'time'

module AssertHelper
  def assert_user001(user)
    assert_equal 'U12345678', user.uuid
    assert_equal 'https://api.calendly.com/users/U12345678', user.uri
    assert_equal 'FooBar', user.name
    assert_equal 'foobar', user.slug
    assert_equal 'foobar@example.com', user.email
    assert_equal 'https://foobar.cloudfront.net/uploads/user/avatar/foobar/foobar.gif', user.avatar_url
    assert_equal 'https://calendly.com/foobar', user.scheduling_url
    assert_equal 'Asia/Tokyo', user.timezone
    assert_equal Time.parse('2020-05-01T00:00:00.000000Z').to_i, user.created_at.to_i
    assert_equal Time.parse('2020-05-02T00:00:00.000000Z').to_i, user.updated_at.to_i
  end

  def assert_event_type001(ev_type)
    assert_equal true, ev_type.active
    assert_equal 'ET0001', ev_type.uuid
    assert_equal '#000001', ev_type.color
    assert_nil ev_type.description_html
    assert_nil ev_type.description_plain
    assert_equal 15, ev_type.duration
    assert_nil ev_type.internal_note
    assert_equal 'solo', ev_type.kind
    assert_equal '15 Minute Meeting', ev_type.name
    assert_nil ev_type.pooling_type
    assert_equal 'https://calendly.com/foobar/15min', ev_type.scheduling_url
    assert_equal '15min', ev_type.slug
    assert_equal 'StandardEventType', ev_type.type
    assert_equal 'https://api.calendly.com/event_types/ET0001', ev_type.uri
    assert_equal Time.parse('2020-07-01T03:00:00.000000Z').to_i, ev_type.created_at.to_i
    assert_equal Time.parse('2020-07-11T03:00:00.000000Z').to_i, ev_type.updated_at.to_i
    assert_equal 'U12345678', ev_type.owner_uuid
    assert_equal 'User', ev_type.owner_type
    assert_equal 'FooBar', ev_type.owner_name
    assert_equal 'https://api.calendly.com/users/U12345678', ev_type.owner_uri
  end

  def assert_event_type002(ev_type)
    assert_equal false, ev_type.active
    assert_equal 'ET0002', ev_type.uuid
    assert_equal '#000002', ev_type.color
    assert_nil ev_type.description_html
    assert_nil ev_type.description_plain
    assert_equal 60, ev_type.duration
    assert_equal 'foo bar notes', ev_type.internal_note
    assert_equal 'solo', ev_type.kind
    assert_equal '60 Minute Meeting', ev_type.name
    assert_nil ev_type.pooling_type
    assert_equal 'https://calendly.com/foobar/60min', ev_type.scheduling_url
    assert_equal '60min', ev_type.slug
    assert_equal 'StandardEventType', ev_type.type
    assert_equal 'https://api.calendly.com/event_types/ET0002', ev_type.uri
    assert_equal Time.parse('2020-07-02T03:00:00.000000Z').to_i, ev_type.created_at.to_i
    assert_equal Time.parse('2020-07-12T03:00:00.000000Z').to_i, ev_type.updated_at.to_i
    assert_equal 'U12345678', ev_type.owner_uuid
    assert_equal 'User', ev_type.owner_type
    assert_equal 'FooBar', ev_type.owner_name
    assert_equal 'https://api.calendly.com/users/U12345678', ev_type.owner_uri
  end

  def assert_event_type003(ev_type)
    assert_equal false, ev_type.active
    assert_equal 'ET0003', ev_type.uuid
    assert_equal '#000003', ev_type.color
    assert_equal '<p>description</p>', ev_type.description_html
    assert_equal 'description', ev_type.description_plain
    assert_equal 30, ev_type.duration
    assert_nil ev_type.internal_note
    assert_equal 'group', ev_type.kind
    assert_equal '30 Minute Meeting', ev_type.name
    assert_nil ev_type.pooling_type
    assert_equal 'https://calendly.com/foobar/30min', ev_type.scheduling_url
    assert_equal '30min', ev_type.slug
    assert_equal 'StandardEventType', ev_type.type
    assert_equal 'https://api.calendly.com/event_types/ET0003', ev_type.uri
    assert_equal Time.parse('2020-07-03T03:00:00.000000Z').to_i, ev_type.created_at.to_i
    assert_equal Time.parse('2020-07-13T03:00:00.000000Z').to_i, ev_type.updated_at.to_i
    assert_equal 'U12345678', ev_type.owner_uuid
    assert_equal 'User', ev_type.owner_type
    assert_equal 'FooBar', ev_type.owner_name
    assert_equal 'https://api.calendly.com/users/U12345678', ev_type.owner_uri
  end

  def assert_event001(ev)
    assert_equal 'EV001', ev.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV001', ev.uri
    assert_equal '30 Minute Meeting', ev.name
    assert_equal 'canceled', ev.status
    assert_equal 'https://api.calendly.com/event_types/ET001', ev.event_type
    assert_equal 'ET001', ev.event_type_uuid
    assert_nil ev.location
    assert_equal 1, ev.invitees_counter_total
    assert_equal 0, ev.invitees_counter_active
    assert_equal 5, ev.invitees_counter_limit
    assert_equal Time.parse('2020-07-22T01:30:00.000000Z').to_i, ev.start_time.to_i
    assert_equal Time.parse('2020-07-22T02:00:00.000000Z').to_i, ev.end_time.to_i
    assert_equal Time.parse('2020-07-10T05:00:00.000000Z').to_i, ev.created_at.to_i
    assert_equal Time.parse('2020-07-11T06:00:00.000000Z').to_i, ev.updated_at.to_i
  end

  def assert_event002(ev)
    assert_equal 'EV002', ev.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV002', ev.uri
    assert_equal '15 Minute Meeting', ev.name
    assert_equal 'active', ev.status
    assert_equal 'https://api.calendly.com/event_types/ET002', ev.event_type
    assert_equal 'ET002', ev.event_type_uuid
    assert_equal 'Tokyo', ev.location
    assert_equal 1, ev.invitees_counter_total
    assert_equal 1, ev.invitees_counter_active
    assert_equal 1, ev.invitees_counter_limit
    assert_equal Time.parse('2020-07-23T01:15:00.000000Z').to_i, ev.start_time.to_i
    assert_equal Time.parse('2020-07-23T01:30:00.000000Z').to_i, ev.end_time.to_i
    assert_equal Time.parse('2020-07-10T06:00:00.000000Z').to_i, ev.created_at.to_i
    assert_equal Time.parse('2020-07-10T07:00:00.000000Z').to_i, ev.updated_at.to_i
  end

  def assert_event003(ev)
    assert_equal 'EV003', ev.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV003', ev.uri
    assert_equal '60 Minute Meeting', ev.name
    assert_equal 'active', ev.status
    assert_equal 'https://api.calendly.com/event_types/ET003', ev.event_type
    assert_equal 'ET003', ev.event_type_uuid
    assert_nil ev.location
    assert_equal 1, ev.invitees_counter_total
    assert_equal 1, ev.invitees_counter_active
    assert_equal 1, ev.invitees_counter_limit
    assert_equal Time.parse('2020-07-24T01:15:00.000000Z').to_i, ev.start_time.to_i
    assert_equal Time.parse('2020-07-24T02:15:00.000000Z').to_i, ev.end_time.to_i
    assert_equal Time.parse('2020-07-13T06:00:00.000000Z').to_i, ev.created_at.to_i
    assert_equal Time.parse('2020-07-13T07:00:00.000000Z').to_i, ev.updated_at.to_i
  end
end
