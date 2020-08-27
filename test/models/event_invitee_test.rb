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
      attrs = { uri: @inv_uri, event: event_uri }
      @invitee = Invitee.new attrs, @client
      @invitee_no_client = Invitee.new attrs
    end

    def test_it_returns_inspect_string
      assert @invitee.inspect.start_with? '#<Calendly::Invitee:'
    end

    def test_that_it_returns_an_error_client_is_not_ready
      proc_client_is_blank = proc do
        @invitee_no_client.fetch
      end
      assert_error proc_client_is_blank, '@client is not ready.'
    end

    def test_that_it_returns_an_associated_invitee
      res_body = load_test_data 'scheduled_event_invitee_101.json'
      add_stub_request :get, @inv_uri, res_body: res_body
      assert_event101_invitee001 @invitee.fetch
    end
  end
end
