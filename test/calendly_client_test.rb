# frozen_string_literal: true

require 'test_helper'

class CalendlyClientTest < CalendlyBaseTest
  def test_that_it_has_a_version_number
    refute_nil ::Calendly::VERSION
  end

  #
  # test for current_user
  #

  def test_that_it_is_returned_a_current_user
    res_body = load_test_data 'user_001.json'
    add_stub_request :get, "#{HOST}/users/me", res_body: res_body

    assert_user001 @client.current_user
    assert_user001 @client.me
  end

  #
  # test for user
  #

  def test_that_it_is_returned_a_specific_user
    res_body = load_test_data 'user_001.json'
    add_stub_request :get, "#{HOST}/users/U12345678", res_body: res_body

    user = @client.user 'U12345678'
    assert_user001 user
  end

  #
  # test for event_types
  #

  def test_that_it_is_returned_all_items_of_event_type
    res_body = load_test_data 'event_types_001.json'
    user_uri = 'https://api.calendly.com/users/U12345678'
    params = { user: user_uri }

    url = "#{HOST}/event_types?#{URI.encode_www_form(params)}"
    add_stub_request(:get, url, res_body: res_body)

    event_types, next_params = @client.event_types user_uri
    assert_equal 3, event_types.length
    assert_nil next_params
    assert_event_type001 event_types[0]
    assert_event_type002 event_types[1]
    assert_event_type003 event_types[2]
  end

  def test_that_it_is_returned_all_items_of_event_type_by_pagination
    user_uri = 'https://api.calendly.com/users/U12345678'

    res_body1 = load_test_data 'event_types_002_page1.json'
    option_params1 = { count: 2, sort: 'created_at:desc' }
    params1 = { user: user_uri }.merge option_params1
    url1 = "#{HOST}/event_types?#{URI.encode_www_form(params1)}"
    add_stub_request(:get, url1, res_body: res_body1)

    res_body2 = load_test_data 'event_types_002_page2.json'
    option_params2 = { count: 2, page_token: 'NEXT_PAGE_TOKEN' }
    params2 = { user: user_uri }.merge option_params2
    url2 = "#{HOST}/event_types?#{URI.encode_www_form(params2)}"
    add_stub_request(:get, url2, res_body: res_body2)

    # request page1
    event_types_page1, next_params1 = @client.event_types user_uri, option_params1
    user_uri_page1 = next_params1.delete(:user)
    # request page2
    event_types_page2, next_params2 = @client.event_types user_uri_page1, next_params1

    assert_equal 2, event_types_page1.length
    assert_equal 1, event_types_page2.length
    assert_nil next_params2
    assert_event_type003 event_types_page1[0]
    assert_event_type002 event_types_page1[1]
    assert_event_type001 event_types_page2[0]
  end

  #
  # test for event
  #

  def test_that_it_is_returned_a_specific_event
    ev_uuid = 'EV001'
    res_body = load_test_data 'scheduled_event_001.json'

    url = "#{HOST}/scheduled_events/#{ev_uuid}"
    add_stub_request(:get, url, res_body: res_body)

    ev = @client.event ev_uuid
    assert_event001 ev
  end

  #
  # test for events
  #

  def test_that_it_is_returned_all_items_of_event
    res_body = load_test_data 'scheduled_events_001.json'
    user_uri = 'https://api.calendly.com/users/U12345678'
    params = { user: user_uri }

    url = "#{HOST}/scheduled_events?#{URI.encode_www_form(params)}"
    add_stub_request(:get, url, res_body: res_body)

    evs, next_params = @client.events user_uri
    assert_equal 2, evs.length
    assert_nil next_params
    assert_event001 evs[0]
    assert_event002 evs[1]
  end

  def test_that_it_is_returned_all_items_of_event_by_pagination
    user_uri = 'https://api.calendly.com/users/U12345678'
    base_params = {
      count: 2,
      invitee_email: 'foobar@example.com',
      max_start_time: '2020-08-01T00:00:00.000000Z',
      min_start_time: '2020-07-01T00:00:00.000000Z',
      user: user_uri,
      status: 'active'
    }
    res_body1 = load_test_data 'scheduled_events_002_page1.json'
    params1 = base_params.merge(
      sort: 'start_time:desc'
    )
    url1 = "#{HOST}/scheduled_events?#{URI.encode_www_form(params1)}"
    add_stub_request(:get, url1, res_body: res_body1)

    res_body2 = load_test_data 'scheduled_events_002_page2.json'
    params2 = base_params.merge(
      page_token: 'NEXT_PAGE_TOKEN'
    )
    url2 = "#{HOST}/scheduled_events?#{URI.encode_www_form(params2)}"
    add_stub_request(:get, url2, res_body: res_body2)

    # request page1
    evs_page1, next_params1 = @client.events user_uri, params1
    user_uri = next_params1.delete(:user)
    # request page2
    evs_page2, next_params2 = @client.events user_uri, next_params1

    assert_equal 2, evs_page1.length
    assert_equal 1, evs_page2.length
    assert_nil next_params2
    assert_event003 evs_page1[0]
    assert_event002 evs_page1[1]
    assert_event001 evs_page2[0]
  end

  #
  # test for event_invitee
  #

  def test_that_it_is_returned_a_one_on_one_event_invitee
    res_body = load_test_data 'scheduled_event_invitee_101.json'
    ev_uuid = 'EV101'
    inv_uuid = 'INV001'

    url = "#{HOST}/scheduled_events/#{ev_uuid}/invitees/#{inv_uuid}"
    add_stub_request(:get, url, res_body: res_body)

    inv = @client.event_invitee ev_uuid, inv_uuid
    assert_event101_invitee001 inv
  end

  #
  # test for event_invitees
  #

  def test_that_it_is_returned_one_on_one_event_invitees
    res_body = load_test_data 'scheduled_event_invitees_101.json'
    ev_uuid = 'EV001'

    url = "#{HOST}/scheduled_events/#{ev_uuid}/invitees"
    add_stub_request(:get, url, res_body: res_body)

    invs, next_params = @client.event_invitees ev_uuid
    assert_equal 1, invs.length
    assert_nil next_params
    assert_event101_invitee001 invs[0]
  end

  def test_that_it_is_returned_group_event_invitees
    ev_uuid = 'EV201'
    base_params = {
      count: 2,
      email: 'foobar@example.com',
      status: 'active'
    }

    res_body1 = load_test_data 'scheduled_event_invitees_201_page1.json'
    params1 = base_params.merge(
      sort: 'created_at:desc'
    )
    url1 = "#{HOST}/scheduled_events/#{ev_uuid}/invitees?#{URI.encode_www_form(params1)}"
    add_stub_request(:get, url1, res_body: res_body1)

    res_body2 = load_test_data 'scheduled_event_invitees_201_page2.json'
    params2 = base_params.merge(
      page_token: 'NEXT_PAGE_TOKEN'
    )
    url2 = "#{HOST}/scheduled_events/#{ev_uuid}/invitees?#{URI.encode_www_form(params2)}"
    add_stub_request(:get, url2, res_body: res_body2)

    # request page1
    invs_page1, next_params1 = @client.event_invitees ev_uuid, params1
    # request page2
    invs_page2, next_params2 = @client.event_invitees ev_uuid, next_params1

    assert_equal 2, invs_page1.length
    assert_equal 1, invs_page2.length
    assert_nil next_params2
    assert_event201_invitee003 invs_page1[0]
    assert_event201_invitee002 invs_page1[1]
    assert_event201_invitee001 invs_page2[0]
  end

  #
  # test for membership
  #

  def test_that_it_is_returned_a_specific_membership
    org_uuid = 'ORG001'
    res_body = load_test_data 'organization_membership_001.json'
    url = "#{HOST}/organization_memberships/#{org_uuid}"
    add_stub_request(:get, url, res_body: res_body)

    mem = @client.membership org_uuid
    assert_org_mem001 mem
  end

  #
  # test for memberships
  #

  def test_that_it_is_returned_all_memberships_by_pagination
    org_uri = 'https://api.calendly.com/organizations/ORG001'
    base_params = {
      organization: org_uri,
      count: 2
    }

    params1 = base_params.dup
    res_body1 = load_test_data 'organization_memberships_002_page1.json'
    url1 = "#{HOST}/organization_memberships?#{URI.encode_www_form(params1)}"
    add_stub_request(:get, url1, res_body: res_body1)

    res_body2 = load_test_data 'organization_memberships_002_page2.json'
    params2 = base_params.merge(
      page_token: 'NEXT_PAGE_TOKEN'
    )
    url2 = "#{HOST}/organization_memberships?#{URI.encode_www_form(params2)}"
    add_stub_request(:get, url2, res_body: res_body2)

    # request page1
    mems_page1, next_params1 = @client.memberships org_uri, params1
    org_uri = next_params1.delete(:organization)
    # request page2
    mems_page2, next_params2 = @client.memberships org_uri, next_params1

    assert_equal 2, mems_page1.length
    assert_equal 1, mems_page2.length
    assert_nil next_params2
    assert_org_mem001 mems_page1[0]
    assert_org_mem002 mems_page1[1]
    assert_org_mem003 mems_page2[0]
  end

  #
  # test for memberships_by_user
  #

  def test_that_it_is_returned_memberships_specific_user
    res_body = load_test_data 'organization_memberships_001.json'
    user_uri = 'https://api.calendly.com/users/U101'

    params = { user: user_uri }
    url = "#{HOST}/organization_memberships?#{URI.encode_www_form(params)}"
    add_stub_request(:get, url, res_body: res_body)

    mems, next_params = @client.memberships_by_user user_uri
    assert_equal 1, mems.length
    assert_nil next_params
    assert_org_mem001 mems[0]
  end
end
