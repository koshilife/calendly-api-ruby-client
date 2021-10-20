# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::EventType
  class EventTypeTest < BaseTest
    def setup
      super
      @et_uuid = 'ET001'
      @et_uri = "#{HOST}/event_types/#{@et_uuid}"
      attrs = {uri: @et_uri}
      @event_type = EventType.new attrs, @client
      @event_type_no_client = EventType.new attrs
    end

    def test_it_returns_inspect_string
      assert @event_type.inspect.start_with? '#<Calendly::EventType:'
    end

    def test_that_it_returns_an_error_client_is_not_ready
      proc_client_is_blank = proc do
        @event_type_no_client.fetch
      end
      assert_error proc_client_is_blank, '@client is not ready.'
    end

    def test_that_it_returns_an_associated_invitee
      res_body = load_test_data 'event_type_001_user.json'
      add_stub_request :get, @et_uri, res_body: res_body
      assert_event_type001 @event_type.fetch
    end

    def test_that_it_creates_schedule_link
      req_body = {
        max_event_count: 3,
        owner: @et_uri,
        owner_type: 'EventType'
      }
      res_body = load_test_data 'schedule_link_001.json'
      url = "#{HOST}/scheduling_links"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201
      assert_schedule_link_001 @event_type.create_schedule_link(max_event_count: 3)
    end

    def test_that_it_parses_uuid_be_formatted_ascii_from_uri
      uuid = 'ff200bd6-af4b-4fd4-a110-e35b2bb5e7ab'
      uri = "#{HOST}/event_types/#{uuid}"
      assert_equal(uuid, EventType.extract_uuid(uri))
    end
  end
end
