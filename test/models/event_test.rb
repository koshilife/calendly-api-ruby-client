# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::Event
  class EventTest < BaseTest
    def setup
      super
      @ev_uuid = 'EV001'
      @ev_uri = "#{HOST}/scheduled_events/#{@ev_uuid}"
      attrs = {uri: @ev_uri}
      @event = Event.new attrs, @client
      @event_no_client = Event.new attrs
    end

    def test_it_returns_inspect_string
      assert @event.inspect.start_with? '#<Calendly::Event:'
    end

    def test_that_it_returns_an_error_client_is_not_ready
      proc_client_is_blank = proc do
        @event_no_client.fetch
      end
      assert_error proc_client_is_blank, '@client is not ready.'
    end

    def test_that_it_returns_an_associated_event
      res_body = load_test_data 'scheduled_event_001.json'
      add_stub_request :get, @ev_uri, res_body: res_body
      assert_event001 @event.fetch
    end

    def test_that_it_returns_event_invitees_in_single_page
      res_body = load_test_data 'scheduled_event_invitees_101.json'
      url = "#{@ev_uri}/invitees"
      add_stub_request :get, url, res_body: res_body

      invs = @event.invitees
      assert_equal 1, invs.length
      assert_event101_invitee001 invs[0]

      # test the fetched data should save in cache.
      WebMock.reset!
      invs = @event.invitees
      assert_equal 1, invs.length
      assert_event101_invitee001 invs[0]

      add_stub_request :get, url, res_body: res_body
      invs = @event.invitees!
      assert_equal 1, invs.length
      assert_event101_invitee001 invs[0]
    end

    def test_that_it_returns_event_invitees_in_plurality_of_pages
      ev = @event.dup
      ev.uuid = 'EV201'
      base_params = {
        count: 2,
        email: 'foobar@example.com',
        status: 'active'
      }

      res_body1 = load_test_data 'scheduled_event_invitees_201_page1.json'
      params1 = base_params.merge(
        sort: 'created_at:desc'
      )
      url1 = "#{HOST}/scheduled_events/#{ev.uuid}/invitees?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'scheduled_event_invitees_201_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/scheduled_events/#{ev.uuid}/invitees?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      invs = ev.invitees params1
      assert_equal 3, invs.length
      assert_event201_invitee003 invs[0]
      assert_event201_invitee002 invs[1]
      assert_event201_invitee001 invs[2]
    end
  end
end
