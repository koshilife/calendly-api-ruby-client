# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::Client
  class ClientTest < BaseTest # rubocop:disable Metrics/ClassLength
    #
    # test for initialize
    #

    def test_that_it_returns_token_empty_error
      proc_generate_client = proc do
        Calendly::Client.new
      end
      assert_required_error proc_generate_client, 'token'
    end

    def test_that_it_configure_client
      init_configuration
      config = Calendly.configuration
      assert_equal @client_id, config.client_id
      assert_equal @client_secret, config.client_secret
      assert_equal @token, config.token
      assert_equal @refresh_token, config.refresh_token
      assert_equal @expires_at, config.token_expires_at
      assert_equal @my_logger, config.logger
      Calendly::Client.new
    end

    def test_that_it_log
      @client.debug_log 'test_debug'
      @client.info_log 'test_info'
      @client.warn_log 'test_warn'
      @client.error_log 'test_error'
    end

    #
    # refresh!
    #

    def test_that_it_exchanges_new_access_token
      init_configuration
      add_refresh_token_stub_request
      client = Calendly::Client.new
      new_token = client.refresh!
      assert_equal 'NEW_TOKEN', new_token.token
      assert_equal 'NEW_REFRESH_TOKEN', new_token.refresh_token
    end

    def test_that_it_raises_an_argument_error_on_refresh!
      proc_refresh = proc do
        @client.refresh!
      end
      assert_required_error proc_refresh, 'client_id'
      Calendly.configuration.client_id = @client_id
      assert_required_error proc_refresh, 'client_secret'
    end

    def test_that_it_returns_an_invalid_token_error_on_initialize
      is_expired = true
      init_configuration(is_expired)
      add_refresh_token_stub_request(is_valid: false)
      proc_invalid_grant = proc do
        Calendly::Client.new
      end
      assert_400_invalid_grant proc_invalid_grant
    end

    #
    # test for current_user
    #

    def test_that_it_returns_a_current_user
      res_body = load_test_data 'user_001.json'
      url = "#{HOST}/users/me"
      add_stub_request :get, url, res_body: res_body
      assert_user001 @client.current_user

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_user001 @client.current_user
      assert_user001 @client.me

      add_stub_request :get, url, res_body: res_body
      assert_user001 @client.current_user!
      assert_user001 @client.me!
    end

    #
    # test for user
    #

    def test_that_it_returns_a_specific_user
      res_body = load_test_data 'user_001.json'
      add_stub_request :get, "#{HOST}/users/U001", res_body: res_body

      user = @client.user 'U001'
      assert_user001 user
    end

    def test_that_it_raises_an_argument_error_on_user
      proc_arg_is_nil = proc do
        @client.user nil
      end
      proc_arg_is_empty = proc do
        @client.user ''
      end
      assert_required_error proc_arg_is_nil, 'uuid_or_uri'
      assert_required_error proc_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for event_type
    #

    def test_that_it_returns_a_specific_event_type
      # data: owner type is user
      et_uuid = 'ET001'
      res_body = load_test_data 'event_type_001_user.json'
      url = "#{HOST}/event_types/#{et_uuid}"
      add_stub_request :get, url, res_body: res_body
      et = @client.event_type et_uuid
      assert_event_type001 et

      # data: owner type is team
      et_uuid = 'ET101'
      res_body = load_test_data 'event_type_101_team.json'
      url = "#{HOST}/event_types/#{et_uuid}"
      add_stub_request :get, url, res_body: res_body
      et = @client.event_type et_uuid
      assert_event_type101 et

      # data: owner type is nothing
      et_uuid = 'ET201'
      res_body = load_test_data 'event_type_201_no_profile.json'
      url = "#{HOST}/event_types/#{et_uuid}"
      add_stub_request :get, url, res_body: res_body
      et = @client.event_type et_uuid
      assert_event_type201 et

      # data: has many questions
      et_uuid = 'ET011'
      res_body = load_test_data 'event_type_011_many_questions.json'
      url = "#{HOST}/event_types/#{et_uuid}"
      add_stub_request :get, url, res_body: res_body
      et = @client.event_type et_uuid
      assert_event_type011 et
    end

    def test_that_it_raises_an_argument_error_on_event_type
      proc_arg_is_empty = proc do
        @client.event_type ''
      end
      assert_required_error proc_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for event_types
    #

    def test_that_it_returns_all_items_of_event_type
      org_uri = 'https://api.calendly.com/organizations/ORG001'
      res_body = load_test_data 'event_types_001.json'
      params = {organization: org_uri}

      url = "#{HOST}/event_types?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      event_types, next_params = @client.event_types org_uri
      assert_equal 3, event_types.length
      assert_nil next_params
      assert_event_type001 event_types[0]
      assert_event_type002 event_types[1]
      assert_event_type003 event_types[2]
    end

    def test_that_it_returns_all_items_of_event_type_across_pages
      org_uri = 'https://api.calendly.com/organizations/ORG001'

      res_body1 = load_test_data 'event_types_002_page1.json'
      option_params1 = {count: 2, sort: 'created_at:desc'}
      params1 = {organization: org_uri}.merge option_params1
      url1 = "#{HOST}/event_types?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'event_types_002_page2.json'
      option_params2 = {count: 2, page_token: 'NEXT_PAGE_TOKEN'}
      params2 = {organization: org_uri}.merge option_params2
      url2 = "#{HOST}/event_types?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      event_types_page1, next_params1 = @client.event_types org_uri, options: option_params1
      org_uri_page1 = next_params1.delete :organization
      # request page2
      event_types_page2, next_params2 = @client.event_types org_uri_page1, options: next_params1

      assert_equal 2, event_types_page1.length
      assert_equal 1, event_types_page2.length
      assert_nil next_params2
      assert_event_type003 event_types_page1[0]
      assert_event_type002 event_types_page1[1]
      assert_event_type001 event_types_page2[0]
    end

    def test_that_it_returns_active_items_of_event_type
      org_uri = 'https://api.calendly.com/organizations/ORG001'
      res_body = load_test_data 'event_types_003.json'
      params = {organization: org_uri, active: true}

      url = "#{HOST}/event_types?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      event_types, next_params = @client.event_types org_uri, options: {active: true}
      assert_equal 1, event_types.length
      assert_nil next_params
      assert_event_type001 event_types[0]
    end

    def test_that_it_raises_an_argument_error_on_event_types
      proc_arg_is_empty = proc do
        @client.event_types ''
      end
      assert_required_error proc_arg_is_empty, 'org_uri'
    end

    #
    # test for event_types_by_user
    #

    def test_that_it_returns_all_items_of_event_type_by_user
      user_uri = 'https://api.calendly.com/users/U001'
      res_body = load_test_data 'event_types_001.json'
      params = {user: user_uri}

      url = "#{HOST}/event_types?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      event_types, next_params = @client.event_types_by_user user_uri
      assert_equal 3, event_types.length
      assert_nil next_params
      assert_event_type001 event_types[0]
      assert_event_type002 event_types[1]
      assert_event_type003 event_types[2]
    end

    def test_that_it_returns_all_items_of_event_type_by_user_across_pages
      user_uri = 'https://api.calendly.com/users/U001'

      res_body1 = load_test_data 'event_types_002_page1_user.json'
      option_params1 = {count: 2, sort: 'created_at:desc'}
      params1 = {user: user_uri}.merge option_params1
      url1 = "#{HOST}/event_types?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'event_types_002_page2.json'
      option_params2 = {count: 2, page_token: 'NEXT_PAGE_TOKEN'}
      params2 = {user: user_uri}.merge option_params2
      url2 = "#{HOST}/event_types?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      event_types_page1, next_params1 = @client.event_types_by_user user_uri, options: option_params1
      user_uri_page1 = next_params1.delete :user
      # request page2
      event_types_page2, next_params2 = @client.event_types_by_user user_uri_page1, options: next_params1

      assert_equal 2, event_types_page1.length
      assert_equal 1, event_types_page2.length
      assert_nil next_params2
      assert_event_type003 event_types_page1[0]
      assert_event_type002 event_types_page1[1]
      assert_event_type001 event_types_page2[0]
    end

    def test_that_it_returns_active_items_of_event_type_by_user
      user_uri = 'https://api.calendly.com/users/U001'
      res_body = load_test_data 'event_types_003.json'
      params = {user: user_uri, active: true}

      url = "#{HOST}/event_types?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      event_types, next_params = @client.event_types_by_user user_uri, options: {active: true}
      assert_equal 1, event_types.length
      assert_nil next_params
      assert_event_type001 event_types[0]
    end

    def test_that_it_raises_an_argument_error_on_event_types_by_user
      proc_arg_is_empty = proc do
        @client.event_types_by_user ''
      end
      assert_required_error proc_arg_is_empty, 'user_uri'
    end

    #
    # test for event_type_available_times
    #

    def test_that_it_returns_available_times_by_specifying_even_type
      now = Time.parse('2022-08-03T01:50:10Z')
      travel_to(now)

      event_type_uri = "#{HOST}/event_types/ET001"
      expected_start_time = '2022-08-03T01:51:10Z' # now + 1 minute
      expected_end_time = '2022-08-10T01:51:10Z' # start_time + 7 days
      params = {event_type: event_type_uri, start_time: expected_start_time, end_time: expected_end_time}

      url = "#{HOST}/event_type_available_times?#{URI.encode_www_form(params)}"
      res_body = load_test_data 'event_type_available_times_001.json'
      add_stub_request :get, url, res_body: res_body

      available_times = @client.event_type_available_times event_type_uri
      assert_available_times001 available_times[0]
      assert_available_times002 available_times[1]
      assert_available_times003 available_times[2]
    end

    def test_that_it_returns_available_times_by_specifying_even_type_and_start_time
      event_type_uri = "#{HOST}/event_types/ET001"
      start_time = Time.parse('2022-08-04T09:00:00Z').utc.iso8601
      expected_end_time = '2022-08-11T09:00:00Z' # start_time + 7 days
      params = {event_type: event_type_uri, start_time: start_time, end_time: expected_end_time}

      url = "#{HOST}/event_type_available_times?#{URI.encode_www_form(params)}"
      res_body = load_test_data 'event_type_available_times_001.json'
      add_stub_request :get, url, res_body: res_body

      available_times = @client.event_type_available_times event_type_uri, start_time: start_time
      assert_available_times001 available_times[0]
      assert_available_times002 available_times[1]
      assert_available_times003 available_times[2]
    end

    def test_that_it_returns_available_times_by_specifying_even_type_and_end_time
      now = Time.parse('2022-08-03T01:50:10Z')
      travel_to(now)

      event_type_uri = "#{HOST}/event_types/ET001"
      expected_start_time = '2022-08-03T01:51:10Z' # now + 1 minute
      end_time = Time.parse('2022-08-05T09:00:00Z').utc.iso8601
      params = {event_type: event_type_uri, start_time: expected_start_time, end_time: end_time}

      url = "#{HOST}/event_type_available_times?#{URI.encode_www_form(params)}"
      res_body = load_test_data 'event_type_available_times_001.json'
      add_stub_request :get, url, res_body: res_body

      available_times = @client.event_type_available_times event_type_uri, end_time: end_time
      assert_available_times001 available_times[0]
      assert_available_times002 available_times[1]
      assert_available_times003 available_times[2]
    end

    def test_that_it_returns_available_times_by_specifying_even_type_and_start_time_and_end_time
      event_type_uri = 'https://api.calendly.com/event_type_available_times'
      start_time = Time.parse('2022-08-04T09:00:00Z').utc.iso8601
      end_time = Time.parse('2022-08-05T09:00:00Z').utc.iso8601
      params = {event_type: event_type_uri, start_time: start_time, end_time: end_time}

      url = "#{HOST}/event_type_available_times?#{URI.encode_www_form(params)}"
      res_body = load_test_data 'event_type_available_times_001.json'
      add_stub_request :get, url, res_body: res_body

      available_times = @client.event_type_available_times event_type_uri, start_time: start_time, end_time: end_time
      assert_available_times001 available_times[0]
      assert_available_times002 available_times[1]
      assert_available_times003 available_times[2]
    end

    def test_that_it_raises_an_argument_error_on_event_type_available_times
      proc_arg_is_empty = proc do
        @client.event_type_available_times ''
      end
      assert_required_error proc_arg_is_empty, 'event_type_uri'
    end

    #
    # test for scheduled_event
    #

    def test_that_it_returns_a_specific_event
      ev_uuid = 'EV001'
      res_body = load_test_data 'scheduled_event_001.json'

      url = "#{HOST}/scheduled_events/#{ev_uuid}"
      add_stub_request :get, url, res_body: res_body

      ev = @client.scheduled_event ev_uuid
      assert_event001 ev
    end

    def test_that_it_raises_an_argument_error_on_event
      proc_arg_is_empty = proc do
        @client.scheduled_event ''
      end
      assert_required_error proc_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for scheduled_events
    #

    def test_that_it_returns_all_items_of_org_event
      org_uri = 'https://api.calendly.com/organizations/ORG001'
      res_body = load_test_data 'scheduled_events_001.json'
      params = {organization: org_uri}

      url = "#{HOST}/scheduled_events?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      evs, next_params = @client.scheduled_events org_uri
      assert_equal 2, evs.length
      assert_nil next_params
      assert_event001 evs[0]
      assert_event002 evs[1]
    end

    def test_that_it_returns_all_items_of_org_event_across_pages # rubocop:disable Metrics/MethodLength
      org_uri = 'https://api.calendly.com/organizations/ORG001'
      base_params = {
        count: 2,
        invitee_email: 'foobar@example.com',
        max_start_time: '2020-08-01T00:00:00.000000Z',
        min_start_time: '2020-07-01T00:00:00.000000Z',
        organization: org_uri,
        status: 'active'
      }
      res_body1 = load_test_data 'scheduled_events_002_page1.json'
      params1 = base_params.merge(
        sort: 'start_time:desc'
      )
      url1 = "#{HOST}/scheduled_events?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'scheduled_events_002_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/scheduled_events?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      evs_page1, next_params1 = @client.scheduled_events org_uri, options: params1
      # org_uri = next_params1.delete :organization
      # request page2
      evs_page2, next_params2 = @client.scheduled_events org_uri, options: next_params1

      assert_equal 2, evs_page1.length
      assert_equal 1, evs_page2.length
      assert_nil next_params2
      assert_event013 evs_page1[0]
      assert_event012 evs_page1[1]
      assert_event011 evs_page2[0]
    end

    def test_that_it_raises_an_argument_error_on_scheduled_events
      proc_arg_is_empty = proc do
        @client.scheduled_events ''
      end
      assert_required_error proc_arg_is_empty, 'org_uri'
    end

    #
    # test for scheduled_events_by_user
    #

    def test_that_it_returns_all_items_of_user_event
      user_uri = 'https://api.calendly.com/users/U001'
      res_body = load_test_data 'scheduled_events_001.json'
      params = {user: user_uri}

      url = "#{HOST}/scheduled_events?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      evs, next_params = @client.scheduled_events_by_user user_uri
      assert_equal 2, evs.length
      assert_nil next_params
      assert_event001 evs[0]
      assert_event002 evs[1]
    end

    def test_that_it_returns_all_items_of_user_event_across_pages # rubocop:disable Metrics/MethodLength
      user_uri = 'https://api.calendly.com/users/U001'
      base_params = {
        count: 2,
        invitee_email: 'foobar@example.com',
        max_start_time: '2020-08-01T00:00:00.000000Z',
        min_start_time: '2020-07-01T00:00:00.000000Z',
        user: user_uri,
        status: 'active'
      }
      res_body1 = load_test_data 'scheduled_events_002_page1_user.json'
      params1 = base_params.merge(
        sort: 'start_time:desc'
      )
      url1 = "#{HOST}/scheduled_events?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'scheduled_events_002_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/scheduled_events?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      evs_page1, next_params1 = @client.scheduled_events_by_user user_uri, options: params1
      user_uri = next_params1.delete :user
      # request page2
      evs_page2, next_params2 = @client.scheduled_events_by_user user_uri, options: next_params1

      assert_equal 2, evs_page1.length
      assert_equal 1, evs_page2.length
      assert_nil next_params2
      assert_event013 evs_page1[0]
      assert_event012 evs_page1[1]
      assert_event011 evs_page2[0]
    end

    def test_that_it_raises_an_argument_error_on_scheduled_events_by_user
      proc_arg_is_empty = proc do
        @client.scheduled_events_by_user ''
      end
      assert_required_error proc_arg_is_empty, 'user_uri'
    end

    #
    # test for cancel_event
    #

    def test_that_it_cancels_a_specific_event
      ev_uuid = 'EV001'
      res_body = load_test_data 'cancel_event_001.json'

      url = "#{HOST}/scheduled_events/#{ev_uuid}/cancellation"
      add_stub_request :post, url, req_body: {}, res_body: res_body

      invitee_cancel = @client.cancel_event ev_uuid
      assert_invitee_cancel001 invitee_cancel
    end

    def test_that_it_cancels_a_specific_event_with_reason
      ev_uuid = 'EV001'
      req_body = {reason: 'something'}
      res_body = load_test_data 'cancel_event_002.json'

      url = "#{HOST}/scheduled_events/#{ev_uuid}/cancellation"
      add_stub_request :post, url, req_body: req_body, res_body: res_body

      invitee_cancel = @client.cancel_event ev_uuid, options: req_body
      assert_invitee_cancel002 invitee_cancel
    end

    def test_that_it_raises_an_argument_error_on_cancel_event
      proc_arg_is_empty = proc do
        @client.cancel_event ''
      end
      assert_required_error proc_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for event_invitee
    #

    def test_that_it_returns_a_one_on_one_event_invitee
      ev_uuid = 'EV101'
      inv_uuid = 'INV001'
      res_body = load_test_data 'scheduled_event_invitee_301.json'

      url = "#{HOST}/scheduled_events/#{ev_uuid}/invitees/#{inv_uuid}"
      add_stub_request :get, url, res_body: res_body

      inv = @client.event_invitee ev_uuid, inv_uuid
      assert_event301_invitee001 inv
    end

    def test_that_it_raises_an_argument_error_on_event_invitee
      proc_ev_uuid_arg_is_empty = proc do
        @client.event_invitee '', 'INV001'
      end
      proc_inv_uuid_arg_is_empty = proc do
        @client.event_invitee 'EV001', ''
      end
      assert_required_error proc_ev_uuid_arg_is_empty, 'invitee_uri_or_ev_uuid'
      assert_required_error proc_inv_uuid_arg_is_empty, 'inv_uuid'
    end

    #
    # test for event_invitees
    #

    def test_that_it_returns_one_on_one_event_invitees
      ev_uuid = 'EV001'
      res_body = load_test_data 'scheduled_event_invitees_101.json'

      url = "#{HOST}/scheduled_events/#{ev_uuid}/invitees"
      add_stub_request :get, url, res_body: res_body

      invs, next_params = @client.event_invitees ev_uuid
      assert_equal 1, invs.length
      assert_nil next_params
      assert_event101_invitee001 invs[0]
    end

    def test_that_it_returns_group_event_invitees # rubocop:disable Metrics/MethodLength
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
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'scheduled_event_invitees_201_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/scheduled_events/#{ev_uuid}/invitees?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      invs_page1, next_params1 = @client.event_invitees ev_uuid, options: params1
      # request page2
      invs_page2, next_params2 = @client.event_invitees ev_uuid, options: next_params1

      assert_equal 2, invs_page1.length
      assert_equal 1, invs_page2.length
      assert_nil next_params2
      assert_event201_invitee003 invs_page1[0]
      assert_event201_invitee002 invs_page1[1]
      assert_event201_invitee001 invs_page2[0]
    end

    def test_that_it_raises_an_argument_error_on_event_invitees
      proc_arg_is_empty = proc do
        @client.event_invitees ''
      end
      assert_required_error proc_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for invitee_no_show
    #

    def test_that_it_returns_a_specific_no_show
      uuid = 'NO_SHOW001'
      res_body = load_test_data 'no_show_001.json'

      url = "#{HOST}/invitee_no_shows/#{uuid}"
      add_stub_request :get, url, res_body: res_body

      no_show = @client.invitee_no_show uuid
      assert_no_show001 no_show
    end

    def test_that_it_raises_an_argument_error_on_invitee_no_show
      proc_arg_is_empty = proc do
        @client.invitee_no_show ''
      end
      assert_required_error proc_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for create_invitee_no_show
    #

    def test_that_it_creates_no_show
      inv_uri = 'https://api.calendly.com/scheduled_events/EV001/invitees/INV001'
      req_body = {invitee: inv_uri}
      res_body = load_test_data 'no_show_001.json'

      url = "#{HOST}/invitee_no_shows"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      no_show = @client.create_invitee_no_show inv_uri
      assert_no_show001 no_show
    end

    def test_that_it_raises_an_argument_error_on_create_invitee_no_show
      proc_arg_is_empty = proc do
        @client.create_invitee_no_show ''
      end
      assert_required_error proc_arg_is_empty, 'invitee_uri'
    end

    #
    # test for delete_invitee_no_show
    #

    def test_that_it_deletes_an_exists_no_show
      uuid = 'NO_SHOW001'
      url = "#{HOST}/invitee_no_shows/#{uuid}"
      add_stub_request :delete, url, res_status: 204

      result = @client.delete_invitee_no_show uuid
      assert_equal true, result
    end

    def test_that_it_raises_an_argument_error_on_delete_invitee_no_show
      proc_arg_is_empty = proc do
        @client.delete_invitee_no_show ''
      end
      assert_required_error proc_arg_is_empty, 'uuid'
    end

    #
    # test for delete_invitee_data
    #

    def test_that_it_deletes_invitee_data
      invitee_emails = ['foo@example.com', 'bar@example.com']
      req_body = {emails: invitee_emails}
      res_body = '{}'

      url = "#{HOST}/data_compliance/deletion/invitees"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 202

      result = @client.delete_invitee_data invitee_emails
      assert_equal true, result
    end

    def test_that_it_raises_an_argument_error_on_delete_invitee_data
      proc_arg_is_empty = proc do
        @client.delete_invitee_data []
      end
      assert_required_error proc_arg_is_empty, 'emails'
    end

    #
    # test for activity_log_entries
    #

    def test_that_it_gets_activity_log_entries
      org_uri = 'https://api.calendly.com/organizations/ORG001'
      req_params = {organization: org_uri}
      res_body = load_test_data 'activity_log_entries_001.json'

      url = "#{HOST}/activity_log_entries?#{URI.encode_www_form(req_params)}"
      add_stub_request :get, url, res_body: res_body

      log_entries, next_page_token, raw_body = @client.activity_log_entries org_uri
      assert_equal 2, log_entries.length
      assert_activity_log_entry001 log_entries[0]
      assert_activity_log_entry002 log_entries[1]
      assert_nil next_page_token
      assert_equal 2, raw_body[:total_count]
      assert_equal false, raw_body[:exceeds_max_total_count]
      assert_equal '2022-10-07T14:21:42Z', raw_body[:last_event_time]
    end

    def test_that_it_gets_activity_log_entries_with_full_options
      org_uri = 'https://api.calendly.com/organizations/ORG001'
      # setup options params
      action = %w[Invite_Sent Succeeded]
      actor = ['https://api.calendly.com/users/U001', 'https://api.calendly.com/users/U002']
      count = 2
      max_occurred_at = '2020-10-01T00:00:00Z'
      min_occurred_at = '2022-08-01T00:00:00Z'
      namespace = %w[Login User_Management]
      page_token = 'NEXT_PAGE_TOKEN'
      search_term = '*@other-website.com'
      sort = ['occurred_at:asc', 'namespace:asc']
      res_body = load_test_data 'activity_log_entries_001.json'
      req_params = {
        organization: org_uri,
        'action[]': action,
        'actor[]': actor,
        count: count,
        max_occurred_at: max_occurred_at,
        min_occurred_at: min_occurred_at,
        'namespace[]': namespace,
        page_token: page_token,
        search_term: search_term,
        'sort[]': sort
      }
      url = "#{HOST}/activity_log_entries?#{URI.encode_www_form(req_params)}"
      add_stub_request :get, url, res_body: res_body

      options = {
        action: action,
        actor: actor,
        count: count,
        max_occurred_at: max_occurred_at,
        min_occurred_at: min_occurred_at,
        namespace: namespace,
        page_token: page_token,
        search_term: search_term,
        sort: sort
      }
      log_entries, = @client.activity_log_entries org_uri, options: options
      assert_equal 2, log_entries.length
      assert_activity_log_entry001 log_entries[0]
      assert_activity_log_entry002 log_entries[1]
    end

    def test_that_it_raises_an_argument_error_on_activity_log_entries
      proc_arg_is_empty = proc do
        @client.activity_log_entries nil
      end
      assert_required_error proc_arg_is_empty, 'org_uri'
    end

    #
    # test for membership
    #

    def test_that_it_returns_a_specific_membership
      mem_uuid = 'MEM001'
      res_body = load_test_data 'organization_membership_001.json'
      url = "#{HOST}/organization_memberships/#{mem_uuid}"
      add_stub_request :get, url, res_body: res_body

      mem = @client.membership mem_uuid
      assert_org_mem001 mem
    end

    def test_that_it_raises_an_argument_error_on_membership
      proc_arg_is_empty = proc do
        @client.membership ''
      end
      assert_required_error proc_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for memberships
    #

    def test_that_it_returns_all_memberships_across_pages # rubocop:disable Metrics/MethodLength
      org_uri = 'https://api.calendly.com/organizations/ORG001'
      base_params = {
        organization: org_uri,
        count: 2
      }

      params1 = base_params.dup
      res_body1 = load_test_data 'organization_memberships_002_page1.json'
      url1 = "#{HOST}/organization_memberships?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'organization_memberships_002_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/organization_memberships?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      mems_page1, next_params1 = @client.memberships org_uri, options: params1
      org_uri = next_params1.delete(:organization)
      # request page2
      mems_page2, next_params2 = @client.memberships org_uri, options: next_params1

      assert_equal 2, mems_page1.length
      assert_equal 1, mems_page2.length
      assert_nil next_params2
      assert_org_mem001 mems_page1[0]
      assert_org_mem002 mems_page1[1]
      assert_org_mem003 mems_page2[0]
    end

    def test_that_it_raises_an_argument_error_on_memberships
      proc_arg_is_empty = proc do
        @client.memberships ''
      end
      assert_required_error proc_arg_is_empty, 'org_uri'
    end

    #
    # test for memberships_by_user
    #

    def test_that_it_returns_memberships_specific_user
      user_uri = 'https://api.calendly.com/users/U101'
      res_body = load_test_data 'organization_memberships_001.json'

      params = {user: user_uri}
      url = "#{HOST}/organization_memberships?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      mems, next_params = @client.memberships_by_user user_uri
      assert_equal 1, mems.length
      assert_nil next_params
      assert_org_mem001 mems[0]
    end

    def test_that_it_raises_an_argument_error_on_memberships_by_user
      proc_arg_is_empty = proc do
        @client.memberships_by_user ''
      end
      assert_required_error proc_arg_is_empty, 'user_uri'
    end

    #
    # test for delete_membership
    #

    def test_that_it_deletes_an_exists_membership
      uuid = 'MEM001'
      url = "#{HOST}/organization_memberships/#{uuid}"
      add_stub_request :delete, url, res_status: 204

      result = @client.delete_membership uuid
      assert_equal true, result
    end

    def test_that_it_raises_an_argument_error_on_delete_membership
      proc_arg_is_empty = proc do
        @client.delete_membership ''
      end
      assert_required_error proc_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for invitation
    #

    def test_that_it_returns_a_specific_invitation
      org_uuid = 'ORG001'
      inv_uuid = 'INV001'
      res_body = load_test_data 'organization_invitation_001.json'
      url = "#{HOST}/organizations/#{org_uuid}/invitations/#{inv_uuid}"
      add_stub_request :get, url, res_body: res_body

      inv = @client.invitation org_uuid, inv_uuid
      assert_org_inv001 inv
    end

    def test_that_it_raises_an_argument_error_on_invitation
      proc_org_uuid_arg_is_empty = proc do
        @client.invitation '', 'INV001'
      end
      proc_inv_uuid_arg_is_empty = proc do
        @client.invitation 'ORG001', ''
      end
      assert_required_error proc_org_uuid_arg_is_empty, 'org_uuid'
      assert_required_error proc_inv_uuid_arg_is_empty, 'inv_uuid'
    end

    #
    # test for invitations
    #

    def test_that_it_returns_all_organization_invitations
      org_uuid = 'ORG001'
      res_body = load_test_data 'organization_invitations_001.json'
      url = "#{HOST}/organizations/#{org_uuid}/invitations"
      add_stub_request :get, url, res_body: res_body

      invs, next_params = @client.invitations org_uuid
      assert_equal 3, invs.length
      assert_nil next_params
      assert_org_inv001 invs[0]
      assert_org_inv002 invs[1]
      assert_org_inv003 invs[2]
    end

    def test_that_it_returns_all_organization_invitations_across_pages
      org_uuid = 'ORG001'
      base_params = {count: 2}

      params1 = base_params.merge(sort: 'created_at:desc')
      res_body1 = load_test_data 'organization_invitations_002_page1.json'
      url1 = "#{HOST}/organizations/#{org_uuid}/invitations?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'organization_invitations_002_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/organizations/#{org_uuid}/invitations?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      invs_page1, next_params1 = @client.invitations org_uuid, options: params1
      # request page2
      invs_page2, next_params2 = @client.invitations org_uuid, options: next_params1

      assert_equal 2, invs_page1.length
      assert_equal 1, invs_page2.length
      assert_nil next_params2
      assert_org_inv003 invs_page1[0]
      assert_org_inv002 invs_page1[1]
      assert_org_inv001 invs_page2[0]
    end

    def test_that_it_raises_an_argument_error_on_invitations
      proc_arg_is_empty = proc do
        @client.invitations ''
      end
      assert_required_error proc_arg_is_empty, 'uuid'
    end

    #
    # test for create_invitation
    #

    def test_that_it_creates_invitation
      org_uuid = 'ORG001'
      email = 'foobar@example.com'
      req_body = {email: email}
      res_body = load_test_data 'organization_invitation_003_create.json'
      url = "#{HOST}/organizations/#{org_uuid}/invitations"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      inv = @client.create_invitation org_uuid, email
      assert_org_inv003 inv
    end

    def test_that_it_raises_an_argument_error_on_create_invitation
      proc_uuid_arg_is_empty = proc do
        @client.create_invitation '', 'foobar@example.com'
      end
      proc_email_arg_is_empty = proc do
        @client.create_invitation 'ORG001', ''
      end
      assert_required_error proc_uuid_arg_is_empty, 'uuid'
      assert_required_error proc_email_arg_is_empty, 'email'
    end

    #
    # test for delete_invitation
    #

    def test_that_it_deletes_invitation
      org_uuid = 'ORG001'
      inv_uuid = 'INV001'
      url = "#{HOST}/organizations/#{org_uuid}/invitations/#{inv_uuid}"
      add_stub_request :delete, url, res_status: 204

      result = @client.delete_invitation org_uuid, inv_uuid
      assert_equal true, result
    end

    def test_that_it_raises_an_argument_error_on_delete_invitation
      proc_org_uuid_arg_is_empty = proc do
        @client.delete_invitation '', 'INV001'
      end
      proc_inv_uuid_arg_is_empty = proc do
        @client.delete_invitation 'ORG001', ''
      end
      assert_required_error proc_org_uuid_arg_is_empty, 'org_uuid'
      assert_required_error proc_inv_uuid_arg_is_empty, 'inv_uuid'
    end

    #
    # test for webhook
    #

    def test_that_it_returns_a_specific_webhook
      uuid = 'ORG_WEBHOOK001'
      res_body = load_test_data 'webhook_organization_001.json'

      url = "#{HOST}/webhook_subscriptions/#{uuid}"
      add_stub_request :get, url, res_body: res_body
      assert_org_webhook_001 @client.webhook uuid
    end

    def test_that_it_raises_an_argument_error_on_webhook
      proc_uuid_arg_is_empty = proc do
        @client.webhook ''
      end
      assert_required_error proc_uuid_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for webhooks
    #

    def test_that_it_returns_all_items_of_webhooks
      org_uri = "#{HOST}/organizations/ORG001"
      res_body = load_test_data 'webhooks_organization_001.json'
      params = {organization: org_uri, scope: 'organization'}

      url = "#{HOST}/webhook_subscriptions?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      webhooks, next_params = @client.webhooks org_uri
      assert_equal 3, webhooks.length
      assert_nil next_params
      assert_org_webhook_001 webhooks[0]
      assert_org_webhook_002 webhooks[1]
      assert_org_webhook_003 webhooks[2]
    end

    def test_that_it_returns_all_items_of_webhooks_across_pages # rubocop:disable Metrics/MethodLength
      org_uri = "#{HOST}/organizations/ORG001"
      base_params = {
        organization: org_uri,
        scope: 'organization',
        count: 2
      }
      res_body1 = load_test_data 'webhooks_organization_002_page1.json'
      params1 = base_params.merge(
        sort: 'created_at:desc'
      )
      url1 = "#{HOST}/webhook_subscriptions?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'webhooks_organization_002_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/webhook_subscriptions?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      webhooks1, next_params1 = @client.webhooks org_uri, options: params1
      org_uri = next_params1.delete :organization
      # request page2
      webhooks2, next_params2 = @client.webhooks org_uri, options: next_params1

      assert_equal 2, webhooks1.length
      assert_equal 1, webhooks2.length
      assert_nil next_params2
      assert_org_webhook_003 webhooks1[0]
      assert_org_webhook_002 webhooks1[1]
      assert_org_webhook_001 webhooks2[0]
    end

    def test_that_it_raises_an_argument_error_on_webhooks
      proc_arg_is_empty = proc do
        @client.webhooks ''
      end
      assert_required_error proc_arg_is_empty, 'org_uri'
    end

    #
    # test for user_scope_webhooks
    #

    def test_that_it_returns_all_items_of_user_webhooks
      org_uri = "#{HOST}/organizations/ORG001"
      user_uri = "#{HOST}/users/U001"
      res_body = load_test_data 'webhooks_user_001.json'
      params = {organization: org_uri, user: user_uri, scope: 'user'}

      url = "#{HOST}/webhook_subscriptions?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      webhooks, next_params = @client.user_scope_webhooks org_uri, user_uri
      assert_equal 3, webhooks.length
      assert_nil next_params
      assert_user_webhook_001 webhooks[0]
      assert_user_webhook_002 webhooks[1]
      assert_user_webhook_003 webhooks[2]
    end

    def test_that_it_returns_all_items_of_user_scope_webhooks_across_pages # rubocop:disable Metrics/MethodLength
      org_uri = "#{HOST}/organizations/ORG001"
      user_uri = "#{HOST}/users/U001"
      base_params = {
        organization: org_uri,
        user: user_uri,
        scope: 'user',
        count: 2
      }
      res_body1 = load_test_data 'webhooks_user_002_page1.json'
      params1 = base_params.merge(
        sort: 'created_at:desc'
      )
      url1 = "#{HOST}/webhook_subscriptions?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'webhooks_user_002_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/webhook_subscriptions?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      webhooks1, next_params1 = @client.user_scope_webhooks org_uri, user_uri, options: params1
      org_uri = next_params1.delete :organization
      # request page2
      webhooks2, next_params2 = @client.user_scope_webhooks org_uri, user_uri, options: next_params1

      assert_equal 2, webhooks1.length
      assert_equal 1, webhooks2.length
      assert_nil next_params2
      assert_user_webhook_003 webhooks1[0]
      assert_user_webhook_002 webhooks1[1]
      assert_user_webhook_001 webhooks2[0]
    end

    def test_that_it_raises_an_argument_error_on_user_scope_webhooks
      org_uri = "#{HOST}/organizations/ORG001"
      user_uri = "#{HOST}/users/U001"
      proc_org_uri_arg_is_empty = proc do
        @client.user_scope_webhooks '', user_uri
      end
      proc_user_uri_arg_is_empty = proc do
        @client.user_scope_webhooks org_uri, ''
      end
      assert_required_error proc_org_uri_arg_is_empty, 'org_uri'
      assert_required_error proc_user_uri_arg_is_empty, 'user_uri'
    end

    #
    # test for create_webhook
    #

    def test_that_it_creates_organization_scope_webhook
      webhook_url = 'https://example.com/organization/webhook001'
      org_uri = "#{HOST}/organizations/ORG001"
      events = ['invitee.created', 'invitee.canceled']
      req_body = {url: webhook_url, events: events, organization: org_uri, scope: 'organization'}
      res_body = load_test_data 'webhook_organization_001.json'

      url = "#{HOST}/webhook_subscriptions"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      webhook = @client.create_webhook webhook_url, events, org_uri
      assert_org_webhook_001 webhook
    end

    def test_that_it_creates_organization_scope_webhook_with_signing_key
      webhook_url = 'https://example.com/organization/webhook001'
      org_uri = "#{HOST}/organizations/ORG001"
      events = ['invitee.created', 'invitee.canceled']
      signing_key = 'secret_string'
      req_body = {
        url: webhook_url, events: events, organization: org_uri,
        scope: 'organization', signing_key: signing_key
      }
      res_body = load_test_data 'webhook_organization_001.json'

      url = "#{HOST}/webhook_subscriptions"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      webhook = @client.create_webhook webhook_url, events, org_uri, signing_key: signing_key
      assert_org_webhook_001 webhook
    end

    def test_that_it_creates_user_scope_webhook
      webhook_url = 'https://example.com/user/webhook001'
      org_uri = "#{HOST}/organizations/ORG001"
      user_uri = "#{HOST}/users/U001"
      events = ['invitee.created', 'invitee.canceled']
      req_body = {url: webhook_url, events: events, organization: org_uri, scope: 'user', user: user_uri}
      res_body = load_test_data 'webhook_user_001.json'

      url = "#{HOST}/webhook_subscriptions"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      webhook = @client.create_webhook webhook_url, events, org_uri, user_uri: user_uri
      assert_user_webhook_001 webhook
    end

    def test_that_it_creates_user_scope_webhook_with_signing_key
      webhook_url = 'https://example.com/user/webhook001'
      org_uri = "#{HOST}/organizations/ORG001"
      user_uri = "#{HOST}/users/U001"
      events = ['invitee.created', 'invitee.canceled']
      signing_key = 'secret_string'
      req_body = {
        url: webhook_url, events: events, organization: org_uri,
        scope: 'user', user: user_uri, signing_key: signing_key
      }
      res_body = load_test_data 'webhook_user_001.json'

      url = "#{HOST}/webhook_subscriptions"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      webhook = @client.create_webhook webhook_url, events, org_uri, user_uri: user_uri, signing_key: signing_key
      assert_user_webhook_001 webhook
    end

    def test_that_it_raises_an_argument_error_on_create_webhook
      webhook_url = 'https://example.com/user/webhook001'
      events = ['invitee.created']
      org_uri = "#{HOST}/organizations/ORG001"
      proc_url_arg_is_empty = proc do
        @client.create_webhook '', events, org_uri
      end
      proc_events_arg_is_empty = proc do
        @client.create_webhook webhook_url, [], org_uri
      end
      proc_org_uri_arg_is_empty = proc do
        @client.create_webhook webhook_url, events, ''
      end
      assert_required_error proc_url_arg_is_empty, 'url'
      assert_required_error proc_events_arg_is_empty, 'events'
      assert_required_error proc_org_uri_arg_is_empty, 'org_uri'
    end

    #
    # test for delete_webhook
    #

    def test_that_it_deletes_webhook
      uuid = 'ORG_WEBHOOK001'
      url = "#{HOST}/webhook_subscriptions/#{uuid}"
      add_stub_request :delete, url, res_status: 204

      result = @client.delete_webhook uuid
      assert_equal true, result
    end

    def test_that_it_raises_an_argument_error_on_delete_webhook
      proc_uuid_arg_is_empty = proc do
        @client.delete_webhook ''
      end
      assert_required_error proc_uuid_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for routing_form
    #

    def test_that_it_returns_a_specific_routing_form
      uuid = 'ROUTING_FORM001'
      res_body = load_test_data 'routing_form_001.json'

      url = "#{HOST}/routing_forms/#{uuid}"
      add_stub_request :get, url, res_body: res_body
      assert_org_routing_form_001 @client.routing_form uuid
    end

    def test_that_it_raises_an_argument_error_on_routing_form
      proc_uuid_arg_is_empty = proc do
        @client.routing_form ''
      end
      assert_required_error proc_uuid_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for routing_forms
    #

    def test_that_it_returns_all_items_of_routing_forms
      org_uri = "#{HOST}/organizations/ORG001"
      res_body = load_test_data 'routing_forms_001.json'
      params = {organization: org_uri}

      url = "#{HOST}/routing_forms?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      forms, next_params = @client.routing_forms org_uri
      assert_equal 3, forms.length
      assert_nil next_params
      assert_org_routing_form_001 forms[0]
      assert_org_routing_form_002 forms[1]
      assert_org_routing_form_003 forms[2]
    end

    def test_that_it_returns_all_items_of_routing_forms_across_pages
      org_uri = "#{HOST}/organizations/ORG001"
      base_params = {
        organization: org_uri,
        count: 2
      }
      res_body1 = load_test_data 'routing_forms_002_page1.json'
      params1 = base_params.merge(
        sort: 'created_at:desc'
      )
      url1 = "#{HOST}/routing_forms?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'routing_forms_002_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/routing_forms?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      forms1, next_params1 = @client.routing_forms org_uri, options: params1
      org_uri = next_params1.delete :organization
      # request page2
      forms2, next_params2 = @client.routing_forms org_uri, options: next_params1

      assert_equal 2, forms1.length
      assert_equal 1, forms2.length
      assert_nil next_params2
      assert_org_routing_form_003 forms1[0]
      assert_org_routing_form_002 forms1[1]
      assert_org_routing_form_001 forms2[0]
    end

    def test_that_it_raises_an_argument_error_on_routing_forms
      proc_arg_is_empty = proc do
        @client.routing_forms ''
      end
      assert_required_error proc_arg_is_empty, 'org_uri'
    end

    #
    # test for routing_form_submission
    #

    def test_that_it_returns_a_specific_routing_form_submission
      uuid = 'SUBMISSION001'
      res_body = load_test_data 'routing_form_submission_001.json'

      url = "#{HOST}/routing_form_submissions/#{uuid}"
      add_stub_request :get, url, res_body: res_body
      assert_org_routing_form_submission_001 @client.routing_form_submission uuid
    end

    def test_that_it_raises_an_argument_error_on_routing_form_submission
      proc_uuid_arg_is_empty = proc do
        @client.routing_form_submission ''
      end
      assert_required_error proc_uuid_arg_is_empty, 'uuid_or_uri'
    end

    #
    # test for routing_form_submissions
    #

    def test_that_it_returns_all_items_of_routing_form_submissions
      form_uri = "#{HOST}/routing_forms/ROUTING_FORM001"
      res_body = load_test_data 'routing_form_submissions_001.json'
      params = {form: form_uri}

      url = "#{HOST}/routing_form_submissions?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      submissions, next_params = @client.routing_form_submissions form_uri
      assert_equal 3, submissions.length
      assert_nil next_params
      assert_org_routing_form_submission_001 submissions[0]
      assert_org_routing_form_submission_002 submissions[1]
      assert_org_routing_form_submission_003 submissions[2]
    end

    def test_that_it_returns_all_items_of_routing_form_submissions_across_pages
      form_uri = "#{HOST}/routing_forms/ROUTING_FORM001"
      base_params = {
        form: form_uri,
        count: 2
      }
      res_body1 = load_test_data 'routing_form_submissions_002_page1.json'
      params1 = base_params.merge(
        sort: 'created_at:desc'
      )
      url1 = "#{HOST}/routing_form_submissions?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'routing_form_submissions_002_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/routing_form_submissions?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      submissions1, next_params1 = @client.routing_form_submissions form_uri, options: params1
      form_uri = next_params1.delete :form
      # request page2
      submissions2, next_params2 = @client.routing_form_submissions form_uri, options: next_params1

      assert_equal 2, submissions1.length
      assert_equal 1, submissions2.length
      assert_nil next_params2
      assert_org_routing_form_submission_003 submissions1[0]
      assert_org_routing_form_submission_002 submissions1[1]
      assert_org_routing_form_submission_001 submissions2[0]
    end

    def test_that_it_raises_an_argument_error_on_routing_form_submissions
      proc_arg_is_empty = proc do
        @client.routing_form_submissions ''
      end
      assert_required_error proc_arg_is_empty, 'form_uri'
    end

    #
    # Following tests are handling to an api error.
    #

    def test_that_it_raises_an_api_error_if_ng_status_is_returned
      not_exist_user_id = 'NOT_EXSIT_USER'
      res_body = load_test_data 'error_404_not_found.json'
      url = "#{HOST}/users/#{not_exist_user_id}"
      add_stub_request :get, url, res_body: res_body, res_status: 404

      proc_404_error = proc do
        @client.user not_exist_user_id
      end
      assert_404_error proc_404_error
    end

    def test_that_it_raises_an_api_error_if_ok_status_not_json_is_returned
      user_id = 'U001'
      res_body = load_test_data 'not_json.html'
      url = "#{HOST}/users/#{user_id}"
      add_stub_request :get, url, res_body: res_body, res_status: 200

      proc_error = proc do
        @client.user user_id
      end
      assert_api_error proc_error, 200, res_body
    end

    def test_that_it_raises_an_api_error_if_ng_status_not_json_is_returned
      user_id = 'U001'
      res_body = load_test_data 'not_json.html'
      url = "#{HOST}/users/#{user_id}"
      add_stub_request :get, url, res_body: res_body, res_status: 400

      proc_error = proc do
        @client.user user_id
      end
      assert_api_error proc_error, 400, res_body
    end

    #
    # test for create_schedule_link
    #

    def test_that_it_creates_schedule_link
      max_event_count = 1
      resource_uri = "#{HOST}/resource/0001"
      owner_type = 'FooBar'
      req_body = {
        max_event_count: max_event_count,
        owner: resource_uri,
        owner_type: owner_type
      }
      res_body = load_test_data 'schedule_link_001.json'
      url = "#{HOST}/scheduling_links"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201
      assert_schedule_link_001 @client.create_schedule_link(resource_uri, owner_type: owner_type)
    end

    def test_that_it_raises_an_argument_error_on_create_schedule_link
      proc_uri_arg_is_empty = proc do
        @client.create_schedule_link ''
      end
      assert_required_error proc_uri_arg_is_empty, 'uri'

      proc_max_event_count_arg_is_empty = proc do
        @client.create_schedule_link 'uri', max_event_count: nil
      end
      assert_required_error proc_max_event_count_arg_is_empty, 'max_event_count'

      proc_owner_type_arg_is_empty = proc do
        @client.create_schedule_link 'uri', owner_type: nil
      end
      assert_required_error proc_owner_type_arg_is_empty, 'owner_type'
    end

  private

    def add_refresh_token_stub_request(is_valid: true)
      req_params = {
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: 'refresh_token',
        refresh_token: @refresh_token
      }
      req_body = URI.encode_www_form(req_params)
      if is_valid
        res_status = 200
        res_body = load_test_data 'refresh_token.json'
      else
        res_status = 400
        res_body = load_test_data 'error_400_invalid_grant.json'
      end
      url = "#{Calendly::Client::AUTH_API_HOST}/oauth/token"
      stub_request(:post, url).with(body: req_body).
        to_return(status: res_status, body: res_body, headers: default_response_headers)
    end
  end
end
