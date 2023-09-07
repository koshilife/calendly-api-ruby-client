# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::Organization
  class OrganizationTest < BaseTest
    def setup
      super
      @org_uuid = 'ORG001'
      @org_uri = "#{HOST}/organizations/#{@org_uuid}"
      @org_params = {organization: @org_uri}
      attrs = {uri: @org_uri}
      @org = Organization.new attrs, @client
    end

    def test_it_returns_inspect_string
      assert @org.inspect.start_with? '#<Calendly::Organization:'
    end

    def test_that_it_returns_memberships_in_single_page
      res_body = load_test_data 'organization_memberships_001.json'
      url = "#{HOST}/organization_memberships?#{URI.encode_www_form(@org_params)}"
      add_stub_request :get, url, res_body: res_body

      assert_mems = proc do |mems|
        assert_equal 1, mems.length
        assert_org_mem001 mems[0]
      end
      assert_mems.call @org.memberships

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_mems.call @org.memberships

      add_stub_request :get, url, res_body: res_body
      assert_mems.call @org.memberships!
    end

    def test_that_it_returns_memberships_across_pages
      params1 = @org_params.merge(count: 2)
      res_body1 = load_test_data 'organization_memberships_002_page1.json'
      url1 = "#{HOST}/organization_memberships?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      params2 = params1.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      res_body2 = load_test_data 'organization_memberships_002_page2.json'
      url2 = "#{HOST}/organization_memberships?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      mems = @org.memberships options: params1
      assert_equal 3, mems.length
      assert_org_mem001 mems[0]
      assert_org_mem002 mems[1]
      assert_org_mem003 mems[2]
    end

    def test_that_it_returns_invitations_in_single_page
      res_body = load_test_data 'organization_invitations_001.json'
      url = "#{@org_uri}/invitations"
      add_stub_request :get, url, res_body: res_body

      assert_invs = proc do |invs|
        assert_equal 3, invs.length
        assert_org_inv001 invs[0]
        assert_org_inv002 invs[1]
        assert_org_inv003 invs[2]
      end
      assert_invs.call @org.invitations

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_invs.call @org.invitations

      add_stub_request :get, url, res_body: res_body
      assert_invs.call @org.invitations!
    end

    def test_that_it_returns_invitations_across_pages
      base_params = {count: 2}
      params1 = base_params.merge(sort: 'created_at:desc')
      res_body1 = load_test_data 'organization_invitations_002_page1.json'
      url1 = "#{@org_uri}/invitations?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      res_body2 = load_test_data 'organization_invitations_002_page2.json'
      url2 = "#{@org_uri}/invitations?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      invs = @org.invitations options: params1
      assert_equal 3, invs.length
      assert_org_inv003 invs[0]
      assert_org_inv002 invs[1]
      assert_org_inv001 invs[2]
    end

    def test_that_it_creates_invitation
      email = 'foobar@example.com'
      req_body = {email: email}
      res_body = load_test_data 'organization_invitation_003_create.json'
      url = "#{@org_uri}/invitations"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      inv = @org.create_invitation email
      assert_org_inv003 inv
    end

    def test_that_it_returns_scheduled_events_in_single_page
      res_body = load_test_data 'scheduled_events_001.json'
      url = "#{HOST}/scheduled_events?#{URI.encode_www_form(@org_params)}"
      add_stub_request :get, url, res_body: res_body

      assert_evs = proc do |evs|
        assert_equal 2, evs.length
        assert_event001 evs[0]
        assert_event002 evs[1]
      end
      assert_evs.call @org.scheduled_events

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_evs.call @org.scheduled_events

      add_stub_request :get, url, res_body: res_body
      assert_evs.call @org.scheduled_events!
    end

    def test_that_it_returns_scheduled_events_across_pages
      base_params = @org_params.merge(
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

      evs = @org.scheduled_events options: params1
      assert_equal 3, evs.length
      assert_event013 evs[0]
      assert_event012 evs[1]
      assert_event011 evs[2]
    end

    def test_that_it_returns_event_types_in_single_page
      res_body = load_test_data 'event_types_001.json'
      url = "#{HOST}/event_types?#{URI.encode_www_form(@org_params)}"
      add_stub_request :get, url, res_body: res_body

      assert_event_types = proc do |event_types|
        assert_equal 3, event_types.length
        assert_event_type001 event_types[0]
        assert_event_type002 event_types[1]
        assert_event_type003 event_types[2]
      end
      assert_event_types.call @org.event_types

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_event_types.call @org.event_types

      add_stub_request :get, url, res_body: res_body
      assert_event_types.call @org.event_types!
    end

    def test_that_it_returns_event_types_across_pages
      params1 = @org_params.merge(count: 2, sort: 'created_at:desc')
      url1 = "#{HOST}/event_types?#{URI.encode_www_form(params1)}"
      res_body1 = load_test_data 'event_types_002_page1.json'
      add_stub_request :get, url1, res_body: res_body1

      params2 = @org_params.merge(count: 2, page_token: 'NEXT_PAGE_TOKEN')
      url2 = "#{HOST}/event_types?#{URI.encode_www_form(params2)}"
      res_body2 = load_test_data 'event_types_002_page2.json'
      add_stub_request :get, url2, res_body: res_body2

      event_types = @org.event_types options: params1
      assert_equal 3, event_types.length
      assert_event_type003 event_types[0]
      assert_event_type002 event_types[1]
      assert_event_type001 event_types[2]
    end

    def test_that_it_returns_webhooks_in_single_page
      res_body = load_test_data 'webhooks_organization_001.json'
      params = {
        organization: @org_uri,
        scope: 'organization'
      }
      url = "#{HOST}/webhook_subscriptions?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      assert_webhooks = proc do |webhooks|
        assert_equal 3, webhooks.length
        assert_org_webhook_001 webhooks[0]
        assert_org_webhook_002 webhooks[1]
        assert_org_webhook_003 webhooks[2]
      end
      assert_webhooks.call @org.webhooks

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_webhooks.call @org.webhooks

      add_stub_request :get, url, res_body: res_body
      assert_webhooks.call @org.webhooks!
    end

    def test_that_it_returns_webhooks_across_pages
      base_params = {
        organization: @org_uri,
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

      webhooks = @org.webhooks options: params1
      assert_equal 3, webhooks.length
      assert_org_webhook_003 webhooks[0]
      assert_org_webhook_002 webhooks[1]
      assert_org_webhook_001 webhooks[2]
    end

    def test_that_it_creates_webhook
      webhook_url = 'https://example.com/organization/webhook001'
      events = ['invitee.created', 'invitee.canceled']
      req_body = {url: webhook_url, events: events, organization: @org_uri, scope: 'organization'}
      res_body = load_test_data 'webhook_organization_001.json'

      url = "#{HOST}/webhook_subscriptions"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      assert_org_webhook_001 @org.create_webhook webhook_url, events
    end

    def test_that_it_creates_webhook_with_signing_key
      webhook_url = 'https://example.com/organization/webhook001'
      events = ['invitee.created', 'invitee.canceled', 'routing_form_submission.created']
      signing_key = 'secret_string'
      req_body = {url: webhook_url, events: events, organization: @org_uri, scope: 'organization',
signing_key: signing_key}
      res_body = load_test_data 'webhook_organization_001.json'

      url = "#{HOST}/webhook_subscriptions"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      assert_org_webhook_001 @org.create_webhook webhook_url, events, signing_key: signing_key
    end

    def test_that_it_returns_routing_forms_in_single_page
      res_body = load_test_data 'routing_forms_001.json'
      url = "#{HOST}/routing_forms?#{URI.encode_www_form(@org_params)}"
      add_stub_request :get, url, res_body: res_body

      assert_forms = proc do |forms|
        assert_equal 3, forms.length
        assert_org_routing_form_001 forms[0]
        assert_org_routing_form_002 forms[1]
        assert_org_routing_form_003 forms[2]
      end
      assert_forms.call @org.routing_forms

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_forms.call @org.routing_forms

      add_stub_request :get, url, res_body: res_body
      assert_forms.call @org.routing_forms!
    end

    def test_that_it_returns_routing_forms_across_pages
      base_params = @org_params.merge(count: 2)

      params1 = base_params.merge(sort: 'created_at:desc')
      res_body1 = load_test_data 'routing_forms_002_page1.json'
      url1 = "#{HOST}/routing_forms?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      params2 = base_params.merge(page_token: 'NEXT_PAGE_TOKEN')
      res_body2 = load_test_data 'routing_forms_002_page2.json'
      url2 = "#{HOST}/routing_forms?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      forms = @org.routing_forms options: params1
      assert_equal 3, forms.length
      assert_org_routing_form_003 forms[0]
      assert_org_routing_form_002 forms[1]
      assert_org_routing_form_001 forms[2]
    end

    def test_that_it_parses_uuid_be_formatted_ascii_from_uri
      uuid = '1624634d-0798-49df-80d6-d24b6718a5c6'
      uri = "#{HOST}/organizations/#{uuid}"
      assert_equal(uuid, Organization.extract_uuid(uri))
    end

    #
    # test for activity_log_entries
    #

    def test_that_gets_it_activity_log_entries
      req_params = {organization: @org_uri}
      res_body = load_test_data 'activity_log_entries_001.json'

      url = "#{HOST}/activity_log_entries?#{URI.encode_www_form(req_params)}"
      add_stub_request :get, url, res_body: res_body

      log_entries, next_page_token, raw_body = @org.activity_log_entries
      assert_equal 2, log_entries.length
      assert_activity_log_entry001 log_entries[0]
      assert_activity_log_entry002 log_entries[1]
      assert_nil next_page_token
      assert_equal 2, raw_body[:total_count]
      assert_equal false, raw_body[:exceeds_max_total_count]
      assert_equal '2022-10-07T14:21:42Z', raw_body[:last_event_time]
    end
  end
end
