# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::Invitee
  class InviteeTest < BaseTest
    def setup
      super
      ev_uuid = 'EV101'
      event_uri = "#{HOST}/scheduled_events/#{ev_uuid}"

      @inv_uuid = 'INV001'
      @inv_uri = "#{event_uri}/invitees/#{@inv_uuid}"
      attrs = {uri: @inv_uri, event: event_uri}
      @invitee = Invitee.new attrs, @client

      @invitee_no_show = Invitee.new attrs, @client
      @no_show_uuid = 'NO_SHOW002'
      @no_show_uri = "#{HOST}/invitee_no_shows/#{@no_show_uuid}"
      @invitee_no_show.no_show = InviteeNoShow.new({uri: @no_show_uri}, @client)
    end

    def test_it_returns_inspect_string
      assert @invitee.inspect.start_with? '#<Calendly::Invitee:'
    end


    def test_that_it_returns_an_associated_invitee
      res_body = load_test_data 'scheduled_event_invitee_301.json'
      add_stub_request :get, @inv_uri, res_body: res_body
      assert_event301_invitee001 @invitee.fetch
    end

    def test_that_it_marks_no_show
      req_body = {invitee: @inv_uri}
      res_body = load_test_data 'no_show_001.json'

      url = "#{HOST}/invitee_no_shows"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      assert_nil @invitee.no_show
      result = @invitee.mark_no_show
      assert_no_show001 result
      assert_no_show001 @invitee.no_show
    end

    def test_that_it_marks_no_show_if_already_marked_no_show
      assert_equal false, @invitee_no_show.no_show.nil?
      result = @invitee_no_show.mark_no_show
      assert_equal @no_show_uuid, result.uuid
    end

    def test_that_it_unmarks_no_show
      _invitee = @invitee_no_show.dup
      no_show = _invitee.no_show
      url = "#{HOST}/invitee_no_shows/#{no_show.uuid}"
      add_stub_request :delete, url, res_status: 204

      result = _invitee.unmark_no_show
      assert_equal true, result
      assert_nil _invitee.no_show
    end

    def test_that_it_unmarks_no_show_if_already_unmarked_no_show
      assert_nil @invitee.no_show
      result = @invitee.unmark_no_show
      assert_nil result
    end

    def test_that_it_parses_uuid_be_formatted_ascii_from_uri
      ev_uuid = '71785b54-c482-4b2f-8dbd-45d7635a9d19'
      uuid = '2da7f0a5-f79c-4a85-a55a-3b028ad14b94'
      uri = "#{HOST}/scheduled_events/#{ev_uuid}/invitees/#{uuid}"
      assert_equal(uuid, Invitee.extract_uuid(uri))
      assert_equal(ev_uuid, Invitee.extract_event_uuid(uri))
    end
  end
end
