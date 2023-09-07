# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::OrganizationMembership
  class OrganizationMembershipTest < BaseTest
    def setup
      super
      @mem_uuid = 'MEM001'
      @mem_uri = "#{HOST}/organization_memberships/#{@mem_uuid}"
      @org_uri = "#{HOST}/organizations/ORG001"
      @user_uri = "#{HOST}/users/U001"
      attrs = {uri: @mem_uri, organization: @org_uri, user: @user_uri}
      @mem = OrganizationMembership.new attrs, @client
    end

    def test_it_returns_inspect_string
      assert @mem.inspect.start_with? '#<Calendly::OrganizationMembership:'
    end

    def test_that_it_returns_an_associated_membership
      res_body = load_test_data 'organization_membership_001.json'
      add_stub_request :get, @mem_uri, res_body: res_body
      assert_org_mem001 @mem.fetch
    end

    def test_that_it_deletes_self
      add_stub_request :delete, @mem_uri, res_status: 204
      result = @mem.delete
      assert_equal true, result
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
      assert_webhooks.call @mem.user_scope_webhooks

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_webhooks.call @mem.user_scope_webhooks

      add_stub_request :get, url, res_body: res_body
      assert_webhooks.call @mem.user_scope_webhooks!
    end

    def test_that_it_returns_user_scope_webhooks_across_pages
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

      webhooks = @mem.user_scope_webhooks options: params1
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

      assert_user_webhook_001 @mem.create_user_scope_webhook webhook_url, events
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

      assert_user_webhook_001 @mem.create_user_scope_webhook webhook_url, events, signing_key: signing_key
    end

    def test_that_it_parses_uuid_be_formatted_ascii_from_uri
      uuid = '7276e6ef-2282-4834-92ff-5eae3d5758a1'
      uri = "#{HOST}/organization_memberships/#{uuid}"
      assert_equal(uuid, OrganizationMembership.extract_uuid(uri))
    end
  end
end
