# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::RoutingFormSubmission
  class RoutingFormSubmissionTest < BaseTest
    def setup
      super
      @submission_uuid = 'SUBMISSION001'
      @submission_uri = "#{HOST}/routing_form_submissions/#{@submission_uuid}"
      @submission_params = {form: @submission_uri}
      attrs = {uri: @submission_uri}
      @submission = RoutingFormSubmission.new attrs, @client
    end

    def test_it_returns_inspect_string
      assert @submission.inspect.start_with? '#<Calendly::RoutingFormSubmission:'
    end


    def test_that_it_returns_an_associated_submission
      res_body = load_test_data 'routing_form_submission_001.json'
      add_stub_request :get, @submission_uri, res_body: res_body
      assert_org_routing_form_submission_001 @submission.fetch
    end

    def test_that_it_parses_uuid_be_formatted_ascii_from_uri
      uuid = '1624634d-0798-49df-80d6-d24b6718a5c6'
      uri = "#{HOST}/routing_form_submissions/#{uuid}"
      assert_equal(uuid, RoutingFormSubmission.extract_uuid(uri))
    end
  end
end
