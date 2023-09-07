# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::WebhookSubscription
  class WebhookSubscriptionTest < BaseTest
    def setup
      super
      @webhook_uuid = 'ORG_WEBHOOK001'
      @webhook_uri = "#{HOST}/webhook_subscriptions/#{@webhook_uuid}"
      attrs = {uri: @webhook_uri}
      @webhook = WebhookSubscription.new attrs, @client
    end

    def test_it_returns_inspect_string
      assert @webhook.inspect.start_with? '#<Calendly::WebhookSubscription:'
    end


    def test_that_it_returns_an_associated_webhook
      res_body = load_test_data 'webhook_organization_001.json'
      add_stub_request :get, @webhook_uri, res_body: res_body
      assert_org_webhook_001 @webhook.fetch
    end

    def test_that_it_deletes_self
      add_stub_request :delete, @webhook_uri, res_status: 204
      result = @webhook.delete
      assert_equal true, result
    end

    def test_that_it_parses_uuid_be_formatted_ascii_from_uri
      uuid = '64190761-e851-410f-9e0a-25cbeebfa550'
      uri = "#{HOST}/webhook_subscriptions/#{uuid}"
      assert_equal(uuid, WebhookSubscription.extract_uuid(uri))
    end
  end
end
