# frozen_string_literal: true

require 'time'

module AssertHelper
  def assert_user001(user)
    assert user.client.is_a? Calendly::Client
    assert_equal 'U001', user.id
    assert_equal 'U001', user.uuid
    assert_equal 'https://api.calendly.com/users/U001', user.uri
    assert_equal 'FooBar', user.name
    assert_equal 'foobar', user.slug
    assert_equal 'foobar@example.com', user.email
    assert_equal 'https://foobar.cloudfront.net/uploads/user/avatar/foobar/foobar.gif', user.avatar_url
    assert_equal 'https://calendly.com/foobar', user.scheduling_url
    assert_equal 'Asia/Tokyo', user.timezone
    assert_equal Time.parse('2020-05-01T00:00:00.000000Z').to_i, user.created_at.to_i
    assert_equal Time.parse('2020-05-02T00:00:00.000000Z').to_i, user.updated_at.to_i
    assert_equal 'ORG001', user.current_organization.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001', user.current_organization.uri
  end

  def assert_user101(user)
    assert user.client.is_a? Calendly::Client
    assert_equal 'U101', user.id
    assert_equal 'U101', user.uuid
    assert_equal 'https://api.calendly.com/users/U101', user.uri
    assert_equal 'FooBar101', user.name
    assert_equal 'foobar101', user.slug
    assert_equal 'foobar101@example.com', user.email
    assert_equal 'https://foobar.cloudfront.net/uploads/user/avatar/foobar/foobar101.gif', user.avatar_url
    assert_equal 'https://calendly.com/foobar101', user.scheduling_url
    assert_equal 'Asia/Tokyo', user.timezone
    assert_equal Time.parse('2020-08-01T00:00:00.000000Z').to_i, user.created_at.to_i
    assert_equal Time.parse('2020-08-01T01:00:00.000000Z').to_i, user.updated_at.to_i
  end

  def assert_user102(user)
    assert user.client.is_a? Calendly::Client
    assert_equal 'U102', user.id
    assert_equal 'U102', user.uuid
    assert_equal 'https://api.calendly.com/users/U102', user.uri
    assert_equal 'FooBar102', user.name
    assert_equal 'foobar102', user.slug
    assert_equal 'foobar102@example.com', user.email
    assert_equal 'https://foobar.cloudfront.net/uploads/user/avatar/foobar/foobar102.gif', user.avatar_url
    assert_equal 'https://calendly.com/foobar102', user.scheduling_url
    assert_equal 'Asia/Tokyo', user.timezone
    assert_equal Time.parse('2020-08-02T00:00:00.000000Z').to_i, user.created_at.to_i
    assert_equal Time.parse('2020-08-02T01:00:00.000000Z').to_i, user.updated_at.to_i
  end

  def assert_user103(user)
    assert user.client.is_a? Calendly::Client
    assert_equal 'U103', user.id
    assert_equal 'U103', user.uuid
    assert_equal 'https://api.calendly.com/users/U103', user.uri
    assert_equal 'FooBar103', user.name
    assert_equal 'foobar103', user.slug
    assert_equal 'foobar103@example.com', user.email
    assert_equal 'https://foobar.cloudfront.net/uploads/user/avatar/foobar/foobar103.gif', user.avatar_url
    assert_equal 'https://calendly.com/foobar103', user.scheduling_url
    assert_equal 'Asia/Tokyo', user.timezone
    assert_equal Time.parse('2020-08-03T00:00:00.000000Z').to_i, user.created_at.to_i
    assert_equal Time.parse('2020-08-03T01:00:00.000000Z').to_i, user.updated_at.to_i
  end

  def assert_event_type001(ev_type)
    assert ev_type.client.is_a? Calendly::Client
    assert_equal true, ev_type.active
    assert_equal 'ET001', ev_type.id
    assert_equal 'ET001', ev_type.uuid
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
    assert_equal 'https://api.calendly.com/event_types/ET001', ev_type.uri
    assert_equal Time.parse('2020-07-01T03:00:00.000000Z').to_i, ev_type.created_at.to_i
    assert_equal Time.parse('2020-07-11T03:00:00.000000Z').to_i, ev_type.updated_at.to_i

    assert ev_type.profile.is_a? Calendly::EventTypeProfile
    assert_equal 'User', ev_type.profile.type
    assert_equal 'https://api.calendly.com/users/U001', ev_type.profile.owner
    assert_equal 'FooBar', ev_type.profile.name
    owner = ev_type.owner_user
    assert owner.is_a? Calendly::User
    assert_equal 'U001', owner.id
    assert_equal 'https://api.calendly.com/users/U001', owner.uri
    assert_nil ev_type.owner_team
    assert_equal [], ev_type.custom_questions
  end

  def assert_event_type002(ev_type)
    assert ev_type.client.is_a? Calendly::Client
    assert_equal false, ev_type.active
    assert_equal 'ET002', ev_type.id
    assert_equal 'ET002', ev_type.uuid
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
    assert_equal 'https://api.calendly.com/event_types/ET002', ev_type.uri
    assert_equal Time.parse('2020-07-02T03:00:00.000000Z').to_i, ev_type.created_at.to_i
    assert_equal Time.parse('2020-07-12T03:00:00.000000Z').to_i, ev_type.updated_at.to_i

    assert ev_type.profile.is_a? Calendly::EventTypeProfile
    assert_equal 'User', ev_type.profile.type
    assert_equal 'https://api.calendly.com/users/U001', ev_type.profile.owner
    assert_equal 'FooBar', ev_type.profile.name
    owner = ev_type.owner_user
    assert owner.is_a? Calendly::User
    assert_equal 'U001', owner.id
    assert_equal 'https://api.calendly.com/users/U001', owner.uri
    assert_nil ev_type.owner_team
    assert_equal [], ev_type.custom_questions
  end

  def assert_event_type003(ev_type)
    assert ev_type.client.is_a? Calendly::Client
    assert_equal false, ev_type.active
    assert_equal 'ET003', ev_type.id
    assert_equal 'ET003', ev_type.uuid
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
    assert_equal 'https://api.calendly.com/event_types/ET003', ev_type.uri
    assert_equal false, ev_type.secret
    assert_equal Time.parse('2020-07-03T03:00:00.000000Z').to_i, ev_type.created_at.to_i
    assert_equal Time.parse('2020-07-13T03:00:00.000000Z').to_i, ev_type.updated_at.to_i

    assert ev_type.profile.is_a? Calendly::EventTypeProfile
    assert_equal 'User', ev_type.profile.type
    assert_equal 'https://api.calendly.com/users/U001', ev_type.profile.owner
    assert_equal 'FooBar', ev_type.profile.name
    owner = ev_type.owner_user
    assert owner.is_a? Calendly::User
    assert_equal 'U001', owner.id
    assert_equal 'https://api.calendly.com/users/U001', owner.uri
    assert_nil ev_type.owner_team
    assert_equal [], ev_type.custom_questions
  end

  def assert_event_type011(ev_type)
    assert ev_type.client.is_a? Calendly::Client
    assert_equal true, ev_type.active
    assert_equal 'ET011', ev_type.id
    assert_equal 'ET011', ev_type.uuid
    assert_equal '#000001', ev_type.color
    assert_equal '<p>FooBar</p>', ev_type.description_html
    assert_equal 'FooBar', ev_type.description_plain
    assert_equal 15, ev_type.duration
    assert_equal 'Internal Note Foobar', ev_type.internal_note
    assert_equal 'solo', ev_type.kind
    assert_equal '15 Minute Meeting', ev_type.name
    assert_equal 'collective', ev_type.pooling_type
    assert_equal 'https://calendly.com/foobar/T001_many_questions', ev_type.scheduling_url
    assert_equal 'T001_many_questions', ev_type.slug
    assert_equal 'StandardEventType', ev_type.type
    assert_equal 'https://api.calendly.com/event_types/ET011', ev_type.uri
    assert_equal true, ev_type.secret
    assert_equal Time.parse('2020-07-01T03:00:00.000000Z').to_i, ev_type.created_at.to_i
    assert_equal Time.parse('2020-07-11T03:00:00.000000Z').to_i, ev_type.updated_at.to_i

    assert ev_type.profile.is_a? Calendly::EventTypeProfile
    assert_equal 'Team', ev_type.profile.type
    assert_equal 'https://api.calendly.com/teams/T001', ev_type.profile.owner
    assert_equal 'Team Page', ev_type.profile.name
    owner = ev_type.owner_team
    assert owner.is_a? Calendly::Team
    assert_equal 'T001', owner.id
    assert_equal 'https://api.calendly.com/teams/T001', owner.uri
    assert_nil ev_type.owner_user

    assert_equal 6, ev_type.custom_questions.length
    question = ev_type.custom_questions[0]
    assert_equal [], question.answer_choices
    assert_equal false, question.enabled
    assert_equal false, question.include_other
    assert_equal 'Please share anything that will help prepare for our meeting.', question.name
    assert_equal 0, question.position
    assert_equal false, question.required
    assert_equal 'text', question.type

    question = ev_type.custom_questions[1]
    assert_equal [], question.answer_choices
    assert_equal true, question.enabled
    assert_equal false, question.include_other
    assert_equal 'One Line', question.name
    assert_equal 1, question.position
    assert_equal false, question.required
    assert_equal 'string', question.type

    question = ev_type.custom_questions[2]
    assert_equal [], question.answer_choices
    assert_equal true, question.enabled
    assert_equal false, question.include_other
    assert_equal 'Multiple Lines', question.name
    assert_equal 2, question.position
    assert_equal true, question.required
    assert_equal 'text', question.type

    question = ev_type.custom_questions[3]
    assert_equal %w[Answer1 Answer2 Answer3], question.answer_choices
    assert_equal true, question.enabled
    assert_equal true, question.include_other
    assert_equal 'Radio Buttons', question.name
    assert_equal 3, question.position
    assert_equal false, question.required
    assert_equal 'single_select', question.type

    question = ev_type.custom_questions[4]
    assert_equal %w[Answer1 Answer2 Answer3], question.answer_choices
    assert_equal true, question.enabled
    assert_equal true, question.include_other
    assert_equal 'CheckBoxes', question.name
    assert_equal 4, question.position
    assert_equal false, question.required
    assert_equal 'multi_select', question.type

    question = ev_type.custom_questions[5]
    assert_equal [], question.answer_choices
    assert_equal true, question.enabled
    assert_equal false, question.include_other
    assert_equal 'Phone Number', question.name
    assert_equal 5, question.position
    assert_equal false, question.required
    assert_equal 'phone_number', question.type
  end

  def assert_event_type101(ev_type)
    assert ev_type.client.is_a? Calendly::Client
    assert_equal true, ev_type.active
    assert_equal 'ET101', ev_type.id
    assert_equal 'ET101', ev_type.uuid
    assert_equal '#000001', ev_type.color
    assert_nil ev_type.description_html
    assert_nil ev_type.description_plain
    assert_equal 15, ev_type.duration
    assert_nil ev_type.internal_note
    assert_equal 'solo', ev_type.kind
    assert_equal '15 Minute Meeting', ev_type.name
    assert_equal 'collective', ev_type.pooling_type
    assert_equal 'https://calendly.com/foobar/T001_15min', ev_type.scheduling_url
    assert_equal 'T001_15min', ev_type.slug
    assert_equal 'StandardEventType', ev_type.type
    assert_equal 'https://api.calendly.com/event_types/ET101', ev_type.uri
    assert_equal false, ev_type.secret
    assert_equal Time.parse('2020-07-01T03:00:00.000000Z').to_i, ev_type.created_at.to_i
    assert_equal Time.parse('2020-07-11T03:00:00.000000Z').to_i, ev_type.updated_at.to_i

    assert ev_type.profile.is_a? Calendly::EventTypeProfile
    assert_equal 'Team', ev_type.profile.type
    assert_equal 'https://api.calendly.com/teams/T001', ev_type.profile.owner
    assert_equal 'Team Page', ev_type.profile.name
    owner = ev_type.owner_team
    assert owner.is_a? Calendly::Team
    assert_equal 'T001', owner.id
    assert_equal 'https://api.calendly.com/teams/T001', owner.uri
    assert_nil ev_type.owner_user
    assert_equal [], ev_type.custom_questions
  end

  def assert_event_type201(ev_type)
    assert ev_type.client.is_a? Calendly::Client
    assert_equal true, ev_type.active
    assert_equal 'ET201', ev_type.id
    assert_equal 'ET201', ev_type.uuid
    assert_equal '#000001', ev_type.color
    assert_nil ev_type.description_html
    assert_nil ev_type.description_plain
    assert_equal 15, ev_type.duration
    assert_nil ev_type.internal_note
    assert_equal 'solo', ev_type.kind
    assert_equal '15 Minute Meeting', ev_type.name
    assert_equal 'round_robin', ev_type.pooling_type
    assert_equal 'https://calendly.com/d/foobar/no_profile_15min', ev_type.scheduling_url
    assert_nil ev_type.slug
    assert_equal 'StandardEventType', ev_type.type
    assert_equal 'https://api.calendly.com/event_types/ET201', ev_type.uri
    assert_equal false, ev_type.secret
    assert_equal Time.parse('2020-07-01T03:00:00.000000Z').to_i, ev_type.created_at.to_i
    assert_equal Time.parse('2020-07-11T03:00:00.000000Z').to_i, ev_type.updated_at.to_i

    assert_nil ev_type.profile
    assert_nil ev_type.owner_user
    assert_nil ev_type.owner_team
    assert_equal [], ev_type.custom_questions
  end

  def assert_event001(ev)
    assert ev.client.is_a? Calendly::Client
    assert_equal 'EV001', ev.id
    assert_equal 'EV001', ev.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV001', ev.uri
    assert_equal '30 Minute Meeting', ev.name
    assert_equal 'canceled', ev.status
    assert_equal 'https://api.calendly.com/event_types/ET001', ev.event_type.uri
    assert_equal 'ET001', ev.event_type.uuid
    assert_nil ev.location
    assert ev.invitees_counter.is_a? Calendly::InviteesCounter
    assert_equal 1, ev.invitees_counter.total
    assert_equal 0, ev.invitees_counter.active
    assert_equal 5, ev.invitees_counter.limit
    assert_equal Time.parse('2020-07-22T01:30:00.000000Z').to_i, ev.start_time.to_i
    assert_equal Time.parse('2020-07-22T02:00:00.000000Z').to_i, ev.end_time.to_i
    assert_equal Time.parse('2020-07-10T05:00:00.000000Z').to_i, ev.created_at.to_i
    assert_equal Time.parse('2020-07-11T06:00:00.000000Z').to_i, ev.updated_at.to_i

    assert_equal 1, ev.event_memberships.length
    user = ev.event_memberships[0]
    assert user.is_a? Calendly::User
    assert_equal 'U001', user.id
    assert_equal 'https://api.calendly.com/users/U001', user.uri

    assert_equal 1, ev.event_guests.length
    guest = ev.event_guests[0]
    assert guest.is_a? Calendly::Guest
    assert_equal 'guest1@example.com', guest.email
    assert_equal Time.parse('2020-07-10T05:00:00.000000Z').to_i, guest.created_at.to_i
    assert_equal Time.parse('2020-07-10T05:00:00.000000Z').to_i, guest.updated_at.to_i
  end

  def assert_event002(ev)
    assert ev.client.is_a? Calendly::Client
    assert_equal 'EV002', ev.id
    assert_equal 'EV002', ev.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV002', ev.uri
    assert_equal '15 Minute Meeting', ev.name
    assert_equal 'active', ev.status
    assert_equal 'https://api.calendly.com/event_types/ET002', ev.event_type.uri
    assert_equal 'ET002', ev.event_type.uuid
    assert_location_tokyo ev.location
    assert ev.invitees_counter.is_a? Calendly::InviteesCounter
    assert_equal 1, ev.invitees_counter.total
    assert_equal 1, ev.invitees_counter.active
    assert_equal 1, ev.invitees_counter.limit
    assert_equal Time.parse('2020-07-23T01:15:00.000000Z').to_i, ev.start_time.to_i
    assert_equal Time.parse('2020-07-23T01:30:00.000000Z').to_i, ev.end_time.to_i
    assert_equal Time.parse('2020-07-10T06:00:00.000000Z').to_i, ev.created_at.to_i
    assert_equal Time.parse('2020-07-10T07:00:00.000000Z').to_i, ev.updated_at.to_i

    assert_equal 1, ev.event_memberships.length
    user = ev.event_memberships[0]
    assert user.is_a? Calendly::User
    assert_equal 'U001', user.id
    assert_equal 'https://api.calendly.com/users/U001', user.uri

    assert_equal 2, ev.event_guests.length
    guest = ev.event_guests[0]
    assert guest.is_a? Calendly::Guest
    assert_equal 'guest2@example.com', guest.email
    assert_equal Time.parse('2020-07-10T06:00:00.000000Z').to_i, guest.created_at.to_i
    assert_equal Time.parse('2020-07-10T06:00:00.000000Z').to_i, guest.updated_at.to_i
    guest = ev.event_guests[1]
    assert guest.is_a? Calendly::Guest
    assert_equal 'guest3@example.com', guest.email
    assert_equal Time.parse('2020-07-10T06:00:00.000000Z').to_i, guest.created_at.to_i
    assert_equal Time.parse('2020-07-10T06:00:00.000000Z').to_i, guest.updated_at.to_i
  end

  def assert_event011(ev)
    assert ev.client.is_a? Calendly::Client
    assert_equal 'EV011', ev.id
    assert_equal 'EV011', ev.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV011', ev.uri
    assert_equal '30 Minute Meeting', ev.name
    assert_equal 'canceled', ev.status
    assert_equal 'https://api.calendly.com/event_types/ET001', ev.event_type.uri
    assert_equal 'ET001', ev.event_type.uuid
    assert_location_microsoft_teams ev.location
    assert ev.invitees_counter.is_a? Calendly::InviteesCounter
    assert_equal 1, ev.invitees_counter.total
    assert_equal 0, ev.invitees_counter.active
    assert_equal 5, ev.invitees_counter.limit
    assert_equal Time.parse('2020-07-22T01:30:00.000000Z').to_i, ev.start_time.to_i
    assert_equal Time.parse('2020-07-22T02:00:00.000000Z').to_i, ev.end_time.to_i
    assert_equal Time.parse('2020-07-10T05:00:00.000000Z').to_i, ev.created_at.to_i
    assert_equal Time.parse('2020-07-11T06:00:00.000000Z').to_i, ev.updated_at.to_i

    assert_equal 2, ev.event_memberships.length
    user = ev.event_memberships[0]
    assert user.is_a? Calendly::User
    assert_equal 'U001', user.id
    assert_equal 'https://api.calendly.com/users/U001', user.uri
    user = ev.event_memberships[1]
    assert user.is_a? Calendly::User
    assert_equal 'U101', user.id
    assert_equal 'https://api.calendly.com/users/U101', user.uri

    assert_equal [], ev.event_guests
  end

  def assert_event012(ev)
    assert ev.client.is_a? Calendly::Client
    assert_equal 'EV012', ev.id
    assert_equal 'EV012', ev.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV012', ev.uri
    assert_equal '15 Minute Meeting', ev.name
    assert_equal 'active', ev.status
    assert_equal 'https://api.calendly.com/event_types/ET002', ev.event_type.uri
    assert_equal 'ET002', ev.event_type.uuid
    assert_location_zoom ev.location
    assert ev.invitees_counter.is_a? Calendly::InviteesCounter
    assert_equal 1, ev.invitees_counter.total
    assert_equal 1, ev.invitees_counter.active
    assert_equal 1, ev.invitees_counter.limit
    assert_equal Time.parse('2020-07-23T01:15:00.000000Z').to_i, ev.start_time.to_i
    assert_equal Time.parse('2020-07-23T01:30:00.000000Z').to_i, ev.end_time.to_i
    assert_equal Time.parse('2020-07-10T06:00:00.000000Z').to_i, ev.created_at.to_i
    assert_equal Time.parse('2020-07-10T07:00:00.000000Z').to_i, ev.updated_at.to_i

    assert_equal 2, ev.event_memberships.length
    user = ev.event_memberships[0]
    assert user.is_a? Calendly::User
    assert_equal 'U001', user.id
    assert_equal 'https://api.calendly.com/users/U001', user.uri
    user = ev.event_memberships[1]
    assert user.is_a? Calendly::User
    assert_equal 'U102', user.id
    assert_equal 'https://api.calendly.com/users/U102', user.uri

    assert_equal [], ev.event_guests
  end

  def assert_event013(ev)
    assert ev.client.is_a? Calendly::Client
    assert_equal 'EV013', ev.id
    assert_equal 'EV013', ev.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV013', ev.uri
    assert_equal '60 Minute Meeting', ev.name
    assert_equal 'active', ev.status
    assert_equal 'https://api.calendly.com/event_types/ET003', ev.event_type.uri
    assert_equal 'ET003', ev.event_type.uuid
    assert_location_google_meet ev.location
    assert ev.invitees_counter.is_a? Calendly::InviteesCounter
    assert_equal 1, ev.invitees_counter.total
    assert_equal 1, ev.invitees_counter.active
    assert_equal 1, ev.invitees_counter.limit
    assert_equal Time.parse('2020-07-24T01:15:00.000000Z').to_i, ev.start_time.to_i
    assert_equal Time.parse('2020-07-24T02:15:00.000000Z').to_i, ev.end_time.to_i
    assert_equal Time.parse('2020-07-13T06:00:00.000000Z').to_i, ev.created_at.to_i
    assert_equal Time.parse('2020-07-13T07:00:00.000000Z').to_i, ev.updated_at.to_i

    assert_equal 2, ev.event_memberships.length
    user = ev.event_memberships[0]
    assert user.is_a? Calendly::User
    assert_equal 'U001', user.id
    assert_equal 'https://api.calendly.com/users/U001', user.uri
    user = ev.event_memberships[1]
    assert user.is_a? Calendly::User
    assert_equal 'U103', user.id
    assert_equal 'https://api.calendly.com/users/U103', user.uri

    assert_equal [], ev.event_guests
  end

  def assert_event101_invitee001(inv)
    assert inv.client.is_a? Calendly::Client
    assert_equal 'INV001', inv.id
    assert_equal 'INV001', inv.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV101/invitees/INV001', inv.uri
    assert_equal 'foobar@example.com', inv.email
    assert_equal 'Foo Bar', inv.name
    assert_equal 'Foo', inv.first_name
    assert_equal 'Bar', inv.last_name
    assert_equal 'active', inv.status
    assert_equal 'Asia/Tokyo', inv.timezone
    assert_equal 'https://api.calendly.com/scheduled_events/EV101', inv.event.uri
    assert_equal 'EV101', inv.event.uuid
    assert_nil inv.text_reminder_number
    assert_equal false, inv.rescheduled
    assert_nil inv.old_invitee
    assert_nil inv.new_invitee
    assert_equal 'https://calendly.com/cancellations/INV001', inv.cancel_url
    assert_equal 'https://calendly.com/reschedulings/INV001', inv.reschedule_url
    assert_equal Time.parse('2020-08-20T01:00:00.000000Z').to_i, inv.created_at.to_i
    assert_equal Time.parse('2020-08-20T01:30:00.000000Z').to_i, inv.updated_at.to_i

    assert_nil inv.cancellation
    assert inv.payment.is_a? Calendly::InviteePayment
    assert_equal 'ch_AAAAAAAAAAAAAAAAAAAAAAAA', inv.payment.external_id
    assert_equal 'stripe', inv.payment.provider
    assert_equal 1234.56, inv.payment.amount
    assert_equal 'USD', inv.payment.currency
    assert_equal 'sample terms of payment (up to 1,024 characters)', inv.payment.terms
    assert_equal true, inv.payment.successful

    assert_equal 5, inv.questions_and_answers.length
    qa = inv.questions_and_answers[0]
    assert_equal "text1\ntext2\ntext3", qa.answer
    assert_equal 0, qa.position
    assert_equal 'Multiple Lines Question', qa.question

    qa = inv.questions_and_answers[1]
    assert_equal 'text1', qa.answer
    assert_equal 1, qa.position
    assert_equal 'One Line Question', qa.question

    qa = inv.questions_and_answers[2]
    assert_equal 'A1', qa.answer
    assert_equal 2, qa.position
    assert_equal 'Radio Buttons Question', qa.question

    qa = inv.questions_and_answers[3]
    assert_equal "A1\nOther", qa.answer
    assert_equal 3, qa.position
    assert_equal 'Checkboxes Question', qa.question

    qa = inv.questions_and_answers[4]
    assert_equal '+81 70-1234-5678', qa.answer
    assert_equal 4, qa.position
    assert_equal 'Phone Number Question', qa.question

    tracking = inv.tracking
    assert_equal 'FOOBAR_CAMPAIGN', tracking.utm_campaign
    assert_equal 'FOOBAR_SOURCE', tracking.utm_source
    assert_equal 'FOOBAR_MEDIUM', tracking.utm_medium
    assert_equal 'FOOBAR_CONTENT', tracking.utm_content
    assert_equal 'FOOBAR_TERM', tracking.utm_term
    assert_equal 'FOOBAR_SALESFORCE_UUID', tracking.salesforce_uuid
  end

  def assert_event201_invitee001(inv)
    assert inv.client.is_a? Calendly::Client
    assert_equal 'INV001', inv.id
    assert_equal 'INV001', inv.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV201/invitees/INV001', inv.uri
    assert_equal 'foobar@example.com', inv.email
    assert_equal 'FooBar', inv.name
    assert_nil inv.first_name
    assert_nil inv.last_name
    assert_equal 'active', inv.status
    assert_equal 'Asia/Tokyo', inv.timezone
    assert_equal 'https://api.calendly.com/scheduled_events/EV201', inv.event.uri
    assert_equal 'EV201', inv.event.uuid
    assert_nil inv.text_reminder_number
    assert_equal false, inv.rescheduled
    assert_nil inv.old_invitee
    assert_nil inv.new_invitee
    assert_equal 'https://calendly.com/cancellations/INV001', inv.cancel_url
    assert_equal 'https://calendly.com/reschedulings/INV001', inv.reschedule_url
    assert_equal Time.parse('2020-08-01T01:00:00.000000Z').to_i, inv.created_at.to_i
    assert_equal Time.parse('2020-08-01T01:30:00.000000Z').to_i, inv.updated_at.to_i

    assert_nil inv.cancellation
    assert_nil inv.payment

    assert_equal 2, inv.questions_and_answers.length
    qa = inv.questions_and_answers[0]
    assert_equal 'A1', qa.answer
    assert_equal 1, qa.position
    assert_equal 'Radio Buttons Question', qa.question

    qa = inv.questions_and_answers[1]
    assert_equal 'A1', qa.answer
    assert_equal 2, qa.position
    assert_equal 'Checkboxes Question', qa.question

    tracking = inv.tracking
    assert_equal 'FOOBAR_CAMPAIGN_1', tracking.utm_campaign
    assert_equal 'FOOBAR_SOURCE_1', tracking.utm_source
    assert_equal 'FOOBAR_MEDIUM_1', tracking.utm_medium
    assert_equal 'FOOBAR_CONTENT_1', tracking.utm_content
    assert_equal 'FOOBAR_TERM_1', tracking.utm_term
    assert_equal 'FOOBAR_SALESFORCE_UUID_1', tracking.salesforce_uuid
  end

  def assert_event201_invitee002(inv)
    assert inv.client.is_a? Calendly::Client
    assert_equal 'INV002', inv.id
    assert_equal 'INV002', inv.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV201/invitees/INV002', inv.uri
    assert_equal 'foobar@example.com', inv.email
    assert_equal 'FooBar', inv.name
    assert_nil inv.first_name
    assert_nil inv.last_name
    assert_equal 'active', inv.status
    assert_equal 'Asia/Tokyo', inv.timezone
    assert_equal 'https://api.calendly.com/scheduled_events/EV201', inv.event.uri
    assert_equal 'EV201', inv.event.uuid
    assert_nil inv.text_reminder_number
    assert_equal false, inv.rescheduled
    assert_equal 'https://api.calendly.com/scheduled_events/EV201_OLD1/invitees/INV002', inv.old_invitee
    assert_nil inv.new_invitee
    assert_equal 'https://calendly.com/cancellations/INV002', inv.cancel_url
    assert_equal 'https://calendly.com/reschedulings/INV002', inv.reschedule_url
    assert_equal Time.parse('2020-08-02T01:00:00.000000Z').to_i, inv.created_at.to_i
    assert_equal Time.parse('2020-08-02T01:30:00.000000Z').to_i, inv.updated_at.to_i

    assert_nil inv.cancellation
    assert_nil inv.payment

    assert_equal 2, inv.questions_and_answers.length
    qa = inv.questions_and_answers[0]
    assert_equal 'A2', qa.answer
    assert_equal 1, qa.position
    assert_equal 'Radio Buttons Question', qa.question

    qa = inv.questions_and_answers[1]
    assert_equal 'A2', qa.answer
    assert_equal 2, qa.position
    assert_equal 'Checkboxes Question', qa.question

    tracking = inv.tracking
    assert_equal 'FOOBAR_CAMPAIGN_2', tracking.utm_campaign
    assert_equal 'FOOBAR_SOURCE_2', tracking.utm_source
    assert_equal 'FOOBAR_MEDIUM_2', tracking.utm_medium
    assert_equal 'FOOBAR_CONTENT_2', tracking.utm_content
    assert_equal 'FOOBAR_TERM_2', tracking.utm_term
    assert_equal 'FOOBAR_SALESFORCE_UUID_2', tracking.salesforce_uuid
  end

  def assert_event201_invitee003(inv)
    assert inv.client.is_a? Calendly::Client
    assert_equal 'INV003', inv.id
    assert_equal 'INV003', inv.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV201/invitees/INV003', inv.uri
    assert_equal 'foobar@example.com', inv.email
    assert_equal 'FooBar', inv.name
    assert_nil inv.first_name
    assert_nil inv.last_name
    assert_equal 'active', inv.status
    assert_equal 'Asia/Tokyo', inv.timezone
    assert_equal 'https://api.calendly.com/scheduled_events/EV201', inv.event.uri
    assert_equal 'EV201', inv.event.uuid
    assert_nil inv.text_reminder_number
    assert_equal false, inv.rescheduled
    assert_nil inv.old_invitee
    assert_nil inv.new_invitee
    assert_equal 'https://calendly.com/cancellations/INV003', inv.cancel_url
    assert_equal 'https://calendly.com/reschedulings/INV003', inv.reschedule_url
    assert_equal Time.parse('2020-08-03T01:00:00.000000Z').to_i, inv.created_at.to_i
    assert_equal Time.parse('2020-08-03T01:30:00.000000Z').to_i, inv.updated_at.to_i

    assert_nil inv.cancellation
    assert_nil inv.payment

    assert_equal 2, inv.questions_and_answers.length
    qa = inv.questions_and_answers[0]
    assert_equal 'A3', qa.answer
    assert_equal 1, qa.position
    assert_equal 'Radio Buttons Question', qa.question

    qa = inv.questions_and_answers[1]
    assert_equal 'A3', qa.answer
    assert_equal 2, qa.position
    assert_equal 'Checkboxes Question', qa.question

    tracking = inv.tracking
    assert_equal 'FOOBAR_CAMPAIGN_3', tracking.utm_campaign
    assert_equal 'FOOBAR_SOURCE_3', tracking.utm_source
    assert_equal 'FOOBAR_MEDIUM_3', tracking.utm_medium
    assert_equal 'FOOBAR_CONTENT_3', tracking.utm_content
    assert_equal 'FOOBAR_TERM_3', tracking.utm_term
    assert_equal 'FOOBAR_SALESFORCE_UUID_3', tracking.salesforce_uuid
  end

  def assert_event301_invitee001(inv)
    assert inv.client.is_a? Calendly::Client
    assert_equal 'INV001', inv.id
    assert_equal 'INV001', inv.uuid
    assert_equal 'https://api.calendly.com/scheduled_events/EV301/invitees/INV001', inv.uri
    assert_equal 'foobar@example.com', inv.email
    assert_equal 'FooBar', inv.name
    assert_nil inv.first_name
    assert_nil inv.last_name
    assert_equal 'canceled', inv.status
    assert_equal 'Asia/Tokyo', inv.timezone
    assert_equal 'https://api.calendly.com/scheduled_events/EV301', inv.event.uri
    assert_equal 'EV301', inv.event.uuid
    assert_equal '12345678', inv.text_reminder_number
    assert_equal true, inv.rescheduled
    assert_equal 'https://api.calendly.com/scheduled_events/EV301_OLD1/invitees/INV001', inv.old_invitee
    assert_equal 'https://api.calendly.com/scheduled_events/EV301_NEW1/invitees/INV001', inv.new_invitee
    assert_equal 'https://calendly.com/cancellations/INV001', inv.cancel_url
    assert_equal 'https://calendly.com/reschedulings/INV001', inv.reschedule_url
    assert_equal Time.parse('2020-08-20T01:00:00.000000Z').to_i, inv.created_at.to_i
    assert_equal Time.parse('2020-08-20T01:30:00.000000Z').to_i, inv.updated_at.to_i

    assert inv.cancellation.is_a? Calendly::InviteeCancellation
    assert_equal 'FooBar', inv.cancellation.canceled_by
    assert_equal 'I have to be absent next week, sorry.', inv.cancellation.reason
    assert_nil inv.payment

    assert_equal 5, inv.questions_and_answers.length
    qa = inv.questions_and_answers[0]
    assert_equal "text1\ntext2\ntext3", qa.answer
    assert_equal 0, qa.position
    assert_equal 'Multiple Lines Question', qa.question

    qa = inv.questions_and_answers[1]
    assert_equal 'text1', qa.answer
    assert_equal 1, qa.position
    assert_equal 'One Line Question', qa.question

    qa = inv.questions_and_answers[2]
    assert_equal 'A1', qa.answer
    assert_equal 2, qa.position
    assert_equal 'Radio Buttons Question', qa.question

    qa = inv.questions_and_answers[3]
    assert_equal "A1\nOther", qa.answer
    assert_equal 3, qa.position
    assert_equal 'Checkboxes Question', qa.question

    qa = inv.questions_and_answers[4]
    assert_equal '+81 70-1234-5678', qa.answer
    assert_equal 4, qa.position
    assert_equal 'Phone Number Question', qa.question

    tracking = inv.tracking
    assert_equal 'FOOBAR_CAMPAIGN', tracking.utm_campaign
    assert_equal 'FOOBAR_SOURCE', tracking.utm_source
    assert_equal 'FOOBAR_MEDIUM', tracking.utm_medium
    assert_equal 'FOOBAR_CONTENT', tracking.utm_content
    assert_equal 'FOOBAR_TERM', tracking.utm_term
    assert_equal 'FOOBAR_SALESFORCE_UUID', tracking.salesforce_uuid
  end

  def assert_location_tokyo(loc)
    assert_equal 'physical', loc.type
    assert_equal 'Tokyo', loc.location
    assert_nil loc.status
    assert_nil loc.join_url
    assert_nil loc.data
  end

  def assert_location_google_meet(loc)
    assert_equal 'google_conference', loc.type
    assert_nil loc.location
    assert_equal 'pushed', loc.status
    assert_equal 'https://calendly.com/events/xxx/google_meet', loc.join_url
    assert_nil loc.data
  end

  def assert_location_zoom(loc)
    assert_equal 'zoom', loc.type
    assert_nil loc.location
    assert_equal 'pushed', loc.status
    assert_equal 'https://us04web.zoom.us/j/12345678901?pwd=NVRRSGRYcW52OHlMMGlXNmpYWHQrQT09', loc.join_url
    expected_data = {
      id: 12_345_678_901,
      settings: {
        field1: 'value1',
        field2: 'value2'
      },
      password: 'NS0dc7',
      extra: nil
    }
    assert_equal expected_data, loc.data
  end

  def assert_location_microsoft_teams(loc)
    assert_equal 'microsoft_teams_conference', loc.type
    assert_nil loc.location
    assert_equal 'pushed', loc.status
    assert_equal 'https://calendly.com/events/xxx/microsoft_teams', loc.join_url
    expected_data = {
      audioConferencing: {
        conferenceId: 'foobar-conferenceId',
        dialinUrl: 'foobar-dialinUrl',
        tollNumber: 'foobar-tollNumber'
      }
    }
    assert_equal expected_data, loc.data
  end

  def assert_org_mem001(org_mem)
    assert org_mem.client.is_a? Calendly::Client
    assert_equal 'MEM001', org_mem.id
    assert_equal 'MEM001', org_mem.uuid
    assert_equal 'https://api.calendly.com/organization_memberships/MEM001', org_mem.uri
    assert_equal 'https://api.calendly.com/organizations/ORG001', org_mem.organization.uri
    assert_equal 'ORG001', org_mem.organization.uuid
    assert_equal 'owner', org_mem.role
    assert_equal Time.parse('2020-07-01T00:00:00.000000Z').to_i, org_mem.created_at.to_i
    assert_equal Time.parse('2020-07-01T01:00:00.000000Z').to_i, org_mem.updated_at.to_i
    assert_user101 org_mem.user
  end

  def assert_org_mem002(org_mem)
    assert org_mem.client.is_a? Calendly::Client
    assert_equal 'MEM002', org_mem.id
    assert_equal 'MEM002', org_mem.uuid
    assert_equal 'https://api.calendly.com/organization_memberships/MEM002', org_mem.uri
    assert_equal 'https://api.calendly.com/organizations/ORG001', org_mem.organization.uri
    assert_equal 'ORG001', org_mem.organization.uuid
    assert_equal 'user', org_mem.role
    assert_equal Time.parse('2020-07-02T00:00:00.000000Z').to_i, org_mem.created_at.to_i
    assert_equal Time.parse('2020-07-02T01:00:00.000000Z').to_i, org_mem.updated_at.to_i
    assert_user102 org_mem.user
  end

  def assert_org_mem003(org_mem)
    assert org_mem.client.is_a? Calendly::Client
    assert_equal 'MEM003', org_mem.id
    assert_equal 'MEM003', org_mem.uuid
    assert_equal 'https://api.calendly.com/organization_memberships/MEM003', org_mem.uri
    assert_equal 'https://api.calendly.com/organizations/ORG001', org_mem.organization.uri
    assert_equal 'ORG001', org_mem.organization.uuid
    assert_equal 'user', org_mem.role
    assert_equal Time.parse('2020-07-03T00:00:00.000000Z').to_i, org_mem.created_at.to_i
    assert_equal Time.parse('2020-07-03T01:00:00.000000Z').to_i, org_mem.updated_at.to_i
    assert_user103 org_mem.user
  end

  def assert_org_inv001(inv)
    assert inv.client.is_a? Calendly::Client
    assert_equal 'INV001', inv.id
    assert_equal 'INV001', inv.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001/invitations/INV001', inv.uri
    assert_equal 'foobar102@example.com', inv.email
    assert_equal 'accepted', inv.status
    assert_equal Time.parse('2020-08-02T00:00:00.000000Z').to_i, inv.created_at.to_i
    assert_equal Time.parse('2020-08-02T01:00:00.000000Z').to_i, inv.updated_at.to_i
    assert_equal Time.parse('2020-08-02T00:30:00.000000Z').to_i, inv.last_sent_at.to_i
    assert_equal 'https://api.calendly.com/organizations/ORG001', inv.organization.uri
    assert_equal 'ORG001', inv.organization.uuid
    assert_equal 'https://api.calendly.com/users/U102', inv.user.uri
    assert_equal 'U102', inv.user.uuid
  end

  def assert_org_inv002(inv)
    assert inv.client.is_a? Calendly::Client
    assert_equal 'INV002', inv.id
    assert_equal 'INV002', inv.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001/invitations/INV002', inv.uri
    assert_equal 'foobar103@example.com', inv.email
    assert_equal 'accepted', inv.status
    assert_equal Time.parse('2020-08-03T00:00:00.000000Z').to_i, inv.created_at.to_i
    assert_equal Time.parse('2020-08-03T01:00:00.000000Z').to_i, inv.updated_at.to_i
    assert_equal Time.parse('2020-08-03T00:30:00.000000Z').to_i, inv.last_sent_at.to_i
    assert_equal 'https://api.calendly.com/organizations/ORG001', inv.organization.uri
    assert_equal 'ORG001', inv.organization.uuid
    assert_equal 'https://api.calendly.com/users/U103', inv.user.uri
    assert_equal 'U103', inv.user.uuid
  end

  def assert_org_inv003(inv)
    assert inv.client.is_a? Calendly::Client
    assert_equal 'INV003', inv.id
    assert_equal 'INV003', inv.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001/invitations/INV003', inv.uri
    assert_equal 'foobar104@example.com', inv.email
    assert_equal 'pending', inv.status
    assert_equal Time.parse('2020-08-04T00:00:00.000000Z').to_i, inv.created_at.to_i
    assert_equal Time.parse('2020-08-04T01:00:00.000000Z').to_i, inv.updated_at.to_i
    assert_equal Time.parse('2020-08-04T00:30:00.000000Z').to_i, inv.last_sent_at.to_i
    assert_equal 'https://api.calendly.com/organizations/ORG001', inv.organization.uri
    assert_equal 'ORG001', inv.organization.uuid
    assert_nil inv.user
  end

  def assert_org_webhook_001(webhook)
    assert webhook.client.is_a? Calendly::Client
    assert_equal 'https://api.calendly.com/webhook_subscriptions/ORG_WEBHOOK001', webhook.uri
    assert_equal 'https://example.com/organization/webhook001', webhook.callback_url
    assert_equal Time.parse('2020-09-17T02:00:00.000000Z'), webhook.created_at
    assert_equal Time.parse('2020-09-17T03:00:00.000000Z'), webhook.updated_at
    assert_equal Time.parse('2020-09-17T04:00:00.000000Z'), webhook.retry_started_at
    assert_equal 'active', webhook.state
    assert_equal ['invitee.created', 'invitee.canceled'], webhook.events
    assert_equal 'organization', webhook.scope
    assert_equal 'ORG001', webhook.organization.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001', webhook.organization.uri
    assert_nil webhook.user
    assert_equal 'U001', webhook.creator.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.creator.uri
  end

  def assert_org_webhook_002(webhook)
    assert webhook.client.is_a? Calendly::Client
    assert_equal 'https://api.calendly.com/webhook_subscriptions/ORG_WEBHOOK002', webhook.uri
    assert_equal 'https://example.com/organization/webhook002', webhook.callback_url
    assert_equal Time.parse('2020-09-18T02:00:00.000000Z'), webhook.created_at
    assert_equal Time.parse('2020-09-18T03:00:00.000000Z'), webhook.updated_at
    assert_equal Time.parse('2020-09-18T04:00:00.000000Z'), webhook.retry_started_at
    assert_equal 'active', webhook.state
    assert_equal ['invitee.created'], webhook.events
    assert_equal 'organization', webhook.scope
    assert_equal 'ORG001', webhook.organization.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001', webhook.organization.uri
    assert_nil webhook.user
    assert_equal 'U001', webhook.creator.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.creator.uri
  end

  def assert_org_webhook_003(webhook)
    assert webhook.client.is_a? Calendly::Client
    assert_equal 'https://api.calendly.com/webhook_subscriptions/ORG_WEBHOOK003', webhook.uri
    assert_equal 'https://example.com/organization/webhook003', webhook.callback_url
    assert_equal Time.parse('2020-09-19T02:00:00.000000Z'), webhook.created_at
    assert_equal Time.parse('2020-09-19T03:00:00.000000Z'), webhook.updated_at
    assert_nil webhook.retry_started_at
    assert_equal 'active', webhook.state
    assert_equal ['invitee.canceled'], webhook.events
    assert_equal 'organization', webhook.scope
    assert_equal 'ORG001', webhook.organization.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001', webhook.organization.uri
    assert_nil webhook.user
    assert_equal 'U001', webhook.creator.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.creator.uri
  end

  def assert_org_webhook_004(webhook)
    assert webhook.client.is_a? Calendly::Client
    assert_equal 'https://api.calendly.com/webhook_subscriptions/ORG_WEBHOOK001', webhook.uri
    assert_equal 'https://example.com/organization/webhook001', webhook.callback_url
    assert_equal Time.parse('2020-09-17T02:00:00.000000Z'), webhook.created_at
    assert_equal Time.parse('2020-09-17T03:00:00.000000Z'), webhook.updated_at
    assert_equal Time.parse('2020-09-17T04:00:00.000000Z'), webhook.retry_started_at
    assert_equal 'secret_string', webhook.signing_key
    assert_equal 'active', webhook.state
    assert_equal ['invitee.created', 'invitee.canceled'], webhook.events
    assert_equal 'organization', webhook.scope
    assert_equal 'ORG001', webhook.organization.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001', webhook.organization.uri
    assert_nil webhook.user
    assert_equal 'U001', webhook.creator.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.creator.uri
  end


  def assert_user_webhook_001(webhook)
    assert webhook.client.is_a? Calendly::Client
    assert_equal 'https://api.calendly.com/webhook_subscriptions/USER_WEBHOOK001', webhook.uri
    assert_equal 'https://example.com/user/webhook001', webhook.callback_url
    assert_equal Time.parse('2020-09-17T02:00:00.000000Z'), webhook.created_at
    assert_equal Time.parse('2020-09-17T03:00:00.000000Z'), webhook.updated_at
    assert_equal Time.parse('2020-09-17T04:00:00.000000Z'), webhook.retry_started_at
    assert_equal 'active', webhook.state
    assert_equal ['invitee.created', 'invitee.canceled'], webhook.events
    assert_equal 'user', webhook.scope
    assert_equal 'ORG001', webhook.organization.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001', webhook.organization.uri
    assert_equal 'U001', webhook.user.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.user.uri
    assert_equal 'U001', webhook.creator.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.creator.uri
  end

  def assert_user_webhook_002(webhook)
    assert webhook.client.is_a? Calendly::Client
    assert_equal 'https://api.calendly.com/webhook_subscriptions/USER_WEBHOOK002', webhook.uri
    assert_equal 'https://example.com/user/webhook002', webhook.callback_url
    assert_equal Time.parse('2020-09-18T02:00:00.000000Z'), webhook.created_at
    assert_equal Time.parse('2020-09-18T03:00:00.000000Z'), webhook.updated_at
    assert_equal Time.parse('2020-09-18T04:00:00.000000Z'), webhook.retry_started_at
    assert_equal 'active', webhook.state
    assert_equal ['invitee.created'], webhook.events
    assert_equal 'user', webhook.scope
    assert_equal 'ORG001', webhook.organization.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001', webhook.organization.uri
    assert_equal 'U001', webhook.user.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.user.uri
    assert_equal 'U001', webhook.creator.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.creator.uri
  end

  def assert_user_webhook_003(webhook)
    assert webhook.client.is_a? Calendly::Client
    assert_equal 'https://api.calendly.com/webhook_subscriptions/USER_WEBHOOK003', webhook.uri
    assert_equal 'https://example.com/user/webhook003', webhook.callback_url
    assert_equal Time.parse('2020-09-19T02:00:00.000000Z'), webhook.created_at
    assert_equal Time.parse('2020-09-19T03:00:00.000000Z'), webhook.updated_at
    assert_nil webhook.retry_started_at
    assert_equal 'active', webhook.state
    assert_equal ['invitee.canceled'], webhook.events
    assert_equal 'user', webhook.scope
    assert_equal 'ORG001', webhook.organization.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001', webhook.organization.uri
    assert_equal 'U001', webhook.user.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.user.uri
    assert_equal 'U001', webhook.creator.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.creator.uri
  end

  def assert_user_webhook_004(webhook)
    assert webhook.client.is_a? Calendly::Client
    assert_equal 'https://api.calendly.com/webhook_subscriptions/USER_WEBHOOK001', webhook.uri
    assert_equal 'https://example.com/user/webhook001', webhook.callback_url
    assert_equal Time.parse('2020-09-17T02:00:00.000000Z'), webhook.created_at
    assert_equal Time.parse('2020-09-17T03:00:00.000000Z'), webhook.updated_at
    assert_equal Time.parse('2020-09-17T04:00:00.000000Z'), webhook.retry_started_at
    assert_equal 'secret_string', webhook.signing_key
    assert_equal 'active', webhook.state
    assert_equal ['invitee.created', 'invitee.canceled'], webhook.events
    assert_equal 'user', webhook.scope
    assert_equal 'ORG001', webhook.organization.uuid
    assert_equal 'https://api.calendly.com/organizations/ORG001', webhook.organization.uri
    assert_equal 'U001', webhook.user.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.user.uri
    assert_equal 'U001', webhook.creator.uuid
    assert_equal 'https://api.calendly.com/users/U001', webhook.creator.uri
  end

  def assert_schedule_link_001(s_link)
    expected = {
      booking_url: 'https://calendly.com/s/FOO-BAR-SLUG',
      owner: 'https://api.calendly.com/event_types/ET001',
      owner_type: 'EventType'
    }
    assert_equal expected, s_link
  end

  def assert_error(proc, ex_message)
    e = assert_raises Calendly::Error do
      proc.call
    end
    assert_equal ex_message, e.message
  end

  def assert_required_error(proc, arg_name)
    assert_error(proc, "#{arg_name} is required.")
  end

  def assert_api_error(proc, ex_status, ex_body, ex_title = nil, ex_message = nil)
    e = assert_raises Calendly::ApiError do
      proc.call
    end
    assert_equal ex_body, e.response.body
    assert_equal ex_status, e.status
    assert_equal ex_title, e.title if ex_title
    assert_equal ex_message, e.message if ex_message
  end

  def assert_400_invalid_grant(proc)
    ex_body = load_test_data 'error_400_invalid_grant.json'
    ex_title = 'invalid_grant'
    ex_message = 'The provided authorization grant is invalid, expired, revoked, does not match the redirection URI used in the authorization request, or was issued to another client.'
    assert_api_error(proc, 400, ex_body, ex_title, ex_message)
  end

  def assert_404_error(proc)
    ex_body = load_test_data 'error_404_not_found.json'
    ex_title = 'Resource Not Found'
    ex_message = 'The server could not find the requested resource.'
    assert_api_error(proc, 404, ex_body, ex_title, ex_message)
  end
end
