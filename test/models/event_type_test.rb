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
    end

    def test_it_returns_inspect_string
      assert @event_type.inspect.start_with? '#<Calendly::EventType:'
    end


    def test_that_it_returns_an_associated_invitee
      res_body = load_test_data 'event_type_001_user.json'
      add_stub_request :get, @et_uri, res_body: res_body
      assert_event_type001 @event_type.fetch
    end

    def test_that_it_returns_available_times
      now = Time.parse('2022-08-03T01:50:10Z')
      travel_to(now)

      expected_start_time = '2022-08-03T01:51:10Z' # now + 1 minute
      expected_end_time = '2022-08-10T01:51:10Z' # start_time + 7 days
      params = {event_type: @et_uri, start_time: expected_start_time, end_time: expected_end_time}

      url = "#{HOST}/event_type_available_times?#{URI.encode_www_form(params)}"
      res_body = load_test_data 'event_type_available_times_001.json'
      add_stub_request :get, url, res_body: res_body

      available_times = @event_type.available_times
      assert_available_times001 available_times[0]
      assert_available_times002 available_times[1]
      assert_available_times003 available_times[2]
    end

    def test_that_it_returns_available_times_by_specifying_start_time
      start_time = Time.parse('2022-08-04T09:00:00Z').utc.iso8601
      expected_end_time = '2022-08-11T09:00:00Z' # start_time + 7 days
      params = {event_type: @et_uri, start_time: start_time, end_time: expected_end_time}

      url = "#{HOST}/event_type_available_times?#{URI.encode_www_form(params)}"
      res_body = load_test_data 'event_type_available_times_001.json'
      add_stub_request :get, url, res_body: res_body

      available_times = @event_type.available_times start_time: start_time
      assert_available_times001 available_times[0]
      assert_available_times002 available_times[1]
      assert_available_times003 available_times[2]
    end

    def test_that_it_returns_available_times_by_specifying_end_time
      now = Time.parse('2022-08-03T01:50:10Z')
      travel_to(now)

      expected_start_time = '2022-08-03T01:51:10Z' # now + 1 minute
      end_time = Time.parse('2022-08-05T09:00:00Z').utc.iso8601
      params = {event_type: @et_uri, start_time: expected_start_time, end_time: end_time}

      url = "#{HOST}/event_type_available_times?#{URI.encode_www_form(params)}"
      res_body = load_test_data 'event_type_available_times_001.json'
      add_stub_request :get, url, res_body: res_body

      available_times = @event_type.available_times end_time: end_time
      assert_available_times001 available_times[0]
      assert_available_times002 available_times[1]
      assert_available_times003 available_times[2]
    end

    def test_that_it_returns_available_times_by_specifying_start_time_and_end_time
      start_time = Time.parse('2022-08-04T09:00:00Z').utc.iso8601
      end_time = Time.parse('2022-08-05T09:00:00Z').utc.iso8601
      params = {event_type: @et_uri, start_time: start_time, end_time: end_time}

      url = "#{HOST}/event_type_available_times?#{URI.encode_www_form(params)}"
      res_body = load_test_data 'event_type_available_times_001.json'
      add_stub_request :get, url, res_body: res_body

      available_times = @event_type.available_times start_time: start_time, end_time: end_time
      assert_available_times001 available_times[0]
      assert_available_times002 available_times[1]
      assert_available_times003 available_times[2]
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
