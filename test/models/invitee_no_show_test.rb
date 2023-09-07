# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::InviteeNoShow
  class InviteeNoShowTest < BaseTest
    def setup
      super
      @no_show_uuid = 'NO_SHOW001'
      @no_show_uri = "#{HOST}/invitee_no_shows/#{@no_show_uuid}"
      attrs = {uri: @no_show_uri}
      @no_show = InviteeNoShow.new attrs, @client
    end

    def test_it_returns_inspect_string
      assert @no_show.inspect.start_with? '#<Calendly::InviteeNoShow:'
    end


    def test_that_it_returns_an_associated_invitee_no_show
      res_body = load_test_data 'no_show_001.json'
      add_stub_request :get, @no_show_uri, res_body: res_body
      assert_no_show001 @no_show.fetch
    end

    def test_that_it_deletes_self
      add_stub_request :delete, @no_show_uri, res_status: 204
      result = @no_show.delete
      assert_equal true, result
    end

    def test_that_it_parses_uuid_be_formatted_ascii_from_uri
      uuid = '45a0213d-b76c-4cd0-8f92-e088c23dd7fe'
      uri = "#{HOST}/invitee_no_shows/#{uuid}"
      assert_equal(uuid, InviteeNoShow.extract_uuid(uri))
    end
  end
end
