# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::User
  class UserTest < BaseTest
    def setup
      super
      @user_uuid = 'U001'
      @user_uri = "#{HOST}/users/#{@user_uuid}"
      @org_uuid = 'ORG001'
      @org_uri = "#{HOST}/organizations/#{@org_uuid}"
      @user_params = {user: @user_uri}
      attrs = {uri: @user_uri, current_organization: @org_uri}
      @user = User.new attrs, @client
    end

    def test_it_returns_inspect_string
      assert @user.inspect.start_with? '#<Calendly::User:'
    end


    def test_that_it_returns_an_associated_user
      res_body = load_test_data 'user_001.json'
      add_stub_request :get, @user_uri, res_body: res_body
      assert_user001 @user.fetch
    end

    def test_that_it_returns_an_associated_organization_membership
      res_body = load_test_data 'organization_memberships_001.json'
      url = "#{HOST}/organization_memberships?#{URI.encode_www_form(@user_params)}"
      add_stub_request :get, url, res_body: res_body
      assert_org_mem001 @user.organization_membership

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_org_mem001 @user.organization_membership

      add_stub_request :get, url, res_body: res_body
      assert_org_mem001 @user.organization_membership!
    end

    def test_that_it_returns_event_types_in_single_page
      res_body = load_test_data 'event_types_001.json'
      url = "#{HOST}/event_types?#{URI.encode_www_form(@user_params)}"
      add_stub_request :get, url, res_body: res_body

      assert_event_types = proc do |event_types|
        assert_equal 3, event_types.length
        assert_event_type001 event_types[0]
        assert_event_type002 event_types[1]
        assert_event_type003 event_types[2]
      end
      assert_event_types.call @user.event_types

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_event_types.call @user.event_types

      add_stub_request :get, url, res_body: res_body
      assert_event_types.call @user.event_types!
    end

    def test_that_it_returns_event_types_across_pages
      params1 = @user_params.merge(count: 2, sort: 'created_at:desc')
      url1 = "#{HOST}/event_types?#{URI.encode_www_form(params1)}"
      res_body1 = load_test_data 'event_types_002_page1_user.json'
      add_stub_request :get, url1, res_body: res_body1

      params2 = @user_params.merge(count: 2, page_token: 'NEXT_PAGE_TOKEN')
      url2 = "#{HOST}/event_types?#{URI.encode_www_form(params2)}"
      res_body2 = load_test_data 'event_types_002_page2.json'
      add_stub_request :get, url2, res_body: res_body2

      event_types = @user.event_types options: params1
      assert_equal 3, event_types.length
      assert_event_type003 event_types[0]
      assert_event_type002 event_types[1]
      assert_event_type001 event_types[2]
    end

    def test_that_it_returns_scheduled_events_in_single_page
      res_body = load_test_data 'scheduled_events_001.json'
      url = "#{HOST}/scheduled_events?#{URI.encode_www_form(@user_params)}"
      add_stub_request :get, url, res_body: res_body

      assert_evs = proc do |evs|
        assert_equal 2, evs.length
        assert_event001 evs[0]
        assert_event002 evs[1]
      end
      assert_evs.call @user.scheduled_events

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_evs.call @user.scheduled_events

      add_stub_request :get, url, res_body: res_body
      assert_evs.call @user.scheduled_events!
    end

    def test_that_it_returns_scheduled_events_across_pages
      base_params = @user_params.merge(
        count: 2,
        invitee_email: 'foobar@example.com',
        max_start_time: '2020-08-01T00:00:00.000000Z',
        min_start_time: '2020-07-01T00:00:00.000000Z',
        status: 'active'
      )
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

      evs = @user.scheduled_events options: params1
      assert_equal 3, evs.length
      assert_event013 evs[0]
      assert_event012 evs[1]
      assert_event011 evs[2]
    end

    def test_that_it_returns_user_scope_webhooks_in_single_page
      res_body = load_test_data 'webhooks_user_001.json'
      params = {
        organization: @org_uri,
        user: @user_uri,
        scope: 'user'
      }
      url = "#{HOST}/webhook_subscriptions?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      assert_webhooks = proc do |webhooks|
        assert_equal 3, webhooks.length
        assert_user_webhook_001 webhooks[0]
        assert_user_webhook_002 webhooks[1]
        assert_user_webhook_003 webhooks[2]
      end
      assert_webhooks.call @user.webhooks

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_webhooks.call @user.webhooks

      add_stub_request :get, url, res_body: res_body
      assert_webhooks.call @user.webhooks!
    end

    def test_that_it_returns_webhooks_across_pages
      base_params = {
        organization: @org_uri,
        user: @user_uri,
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

      webhooks = @user.webhooks options: params1
      assert_equal 3, webhooks.length
      assert_user_webhook_003 webhooks[0]
      assert_user_webhook_002 webhooks[1]
      assert_user_webhook_001 webhooks[2]
    end

    def test_that_it_creates_user_scope_webhook
      webhook_url = 'https://example.com/user/webhook001'
      events = ['invitee.created', 'invitee.canceled']
      req_body = {url: webhook_url, events: events, organization: @org_uri, scope: 'user', user: @user_uri}
      res_body = load_test_data 'webhook_user_001.json'

      url = "#{HOST}/webhook_subscriptions"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      assert_user_webhook_001 @user.create_webhook webhook_url, events
    end

    def test_that_it_creates_user_scope_webhook_with_signing_key
      webhook_url = 'https://example.com/user/webhook001'
      events = ['invitee.created', 'invitee.canceled']
      signing_key = 'secret_string'
      req_body = {url: webhook_url, events: events, organization: @org_uri, scope: 'user', user: @user_uri,
signing_key: signing_key}
      res_body = load_test_data 'webhook_user_001.json'

      url = "#{HOST}/webhook_subscriptions"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      assert_user_webhook_001 @user.create_webhook webhook_url, events, signing_key: signing_key
    end

    def test_that_it_parses_uuid_be_formatted_ascii_from_uri
      uuid = 'fff1e21e-05fb-4070-ad35-f8e1234177c4'
      uri = "#{HOST}/users/#{uuid}"
      assert_equal(uuid, User.extract_uuid(uri))
    end
  end
end
