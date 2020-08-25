# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::User
  class UserTest < BaseTest
    def setup
      super
      @user_uuid = 'U001'
      @user_uri = "#{HOST}/users/#{@user_uuid}"
      @uri_params = { user: @user_uri }
      attrs = { uri: @user_uri }
      @user = User.new attrs, @client
      @user_no_client = User.new attrs
    end

    def test_that_it_returns_an_error_client_is_not_ready
      proc_client_is_blank = proc do
        @user_no_client.fetch
      end
      assert_error proc_client_is_blank, '@client is not ready.'
    end

    def test_that_it_returns_an_associated_user
      res_body = load_test_data 'user_001.json'
      add_stub_request :get, @user_uri, res_body: res_body
      assert_user001 @user.fetch
    end

    def test_that_it_returns_an_associated_organization_membership
      res_body = load_test_data 'organization_memberships_001.json'
      url = "#{HOST}/organization_memberships?#{URI.encode_www_form(@uri_params)}"
      add_stub_request :get, url, res_body: res_body
      assert_org_mem001 @user.organization
    end

    def test_that_it_returns_event_types_in_single_page
      res_body = load_test_data 'event_types_001.json'
      url = "#{HOST}/event_types?#{URI.encode_www_form(@uri_params)}"
      add_stub_request :get, url, res_body: res_body

      event_types = @user.event_types
      assert_equal 3, event_types.length
      assert_event_type001 event_types[0]
      assert_event_type002 event_types[1]
      assert_event_type003 event_types[2]
    end

    def test_that_it_returns_event_types_in_plurality_of_pages
      params1 = @uri_params.merge(count: 2, sort: 'created_at:desc')
      url1 = "#{HOST}/event_types?#{URI.encode_www_form(params1)}"
      res_body1 = load_test_data 'event_types_002_page1.json'
      add_stub_request :get, url1, res_body: res_body1

      params2 = @uri_params.merge(count: 2, page_token: 'NEXT_PAGE_TOKEN')
      url2 = "#{HOST}/event_types?#{URI.encode_www_form(params2)}"
      res_body2 = load_test_data 'event_types_002_page2.json'
      add_stub_request :get, url2, res_body: res_body2

      event_types = @user.event_types params1
      assert_equal 3, event_types.length
      assert_event_type003 event_types[0]
      assert_event_type002 event_types[1]
      assert_event_type001 event_types[2]
    end

    def test_that_it_returns_scheduled_events_in_single_page
      res_body = load_test_data 'scheduled_events_001.json'
      url = "#{HOST}/scheduled_events?#{URI.encode_www_form(@uri_params)}"
      add_stub_request :get, url, res_body: res_body
      evs = @user.scheduled_events
      assert_equal 2, evs.length
      assert_event001 evs[0]
      assert_event002 evs[1]
    end

    def test_that_it_returns_scheduled_events_in_plurality_of_pages
      base_params = @uri_params.merge(
        count: 2,
        invitee_email: 'foobar@example.com',
        max_start_time: '2020-08-01T00:00:00.000000Z',
        min_start_time: '2020-07-01T00:00:00.000000Z',
        status: 'active'
      )
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

      evs = @user.scheduled_events params1
      assert_equal 3, evs.length
      assert_event003 evs[0]
      assert_event002 evs[1]
      assert_event001 evs[2]
    end
  end
end
