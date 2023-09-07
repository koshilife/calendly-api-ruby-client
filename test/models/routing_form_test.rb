# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::RoutingForm
  class RoutingFormTest < BaseTest
    def setup
      super
      @form_uuid = 'ROUTING_FORM001'
      @form_uri = "#{HOST}/routing_forms/#{@form_uuid}"
      @form_params = {form: @form_uri}
      attrs = {uri: @form_uri}
      @form = RoutingForm.new attrs, @client
    end

    def test_it_returns_inspect_string
      assert @form.inspect.start_with? '#<Calendly::RoutingForm:'
    end


    def test_that_it_returns_an_associated_routing_form
      res_body = load_test_data 'routing_form_001.json'
      add_stub_request :get, @form_uri, res_body: res_body
      assert_org_routing_form_001 @form.fetch
    end

    def test_that_it_returns_submissions_in_single_page
      res_body = load_test_data 'routing_form_submissions_001.json'
      url = "#{HOST}/routing_form_submissions?#{URI.encode_www_form(@form_params)}"
      add_stub_request :get, url, res_body: res_body

      assert_forms = proc do |submissions|
        assert_equal 3, submissions.length
        assert_org_routing_form_submission_001 submissions[0]
        assert_org_routing_form_submission_002 submissions[1]
        assert_org_routing_form_submission_003 submissions[2]
      end
      assert_forms.call @form.submissions

      # test the fetched data should save in cache.
      WebMock.reset!
      assert_forms.call @form.submissions

      add_stub_request :get, url, res_body: res_body
      assert_forms.call @form.submissions!
    end

    def test_that_it_returns_submissions_across_pages
      base_params = @form_params.merge(count: 2)

      params1 = base_params.merge(sort: 'created_at:desc')
      res_body1 = load_test_data 'routing_form_submissions_002_page1.json'
      url1 = "#{HOST}/routing_form_submissions?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      params2 = base_params.merge(page_token: 'NEXT_PAGE_TOKEN')
      res_body2 = load_test_data 'routing_form_submissions_002_page2.json'
      url2 = "#{HOST}/routing_form_submissions?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      submissions = @form.submissions options: params1
      assert_equal 3, submissions.length
      assert_org_routing_form_submission_003 submissions[0]
      assert_org_routing_form_submission_002 submissions[1]
      assert_org_routing_form_submission_001 submissions[2]
    end

    def test_that_it_parses_uuid_be_formatted_ascii_from_uri
      uuid = '1624634d-0798-49df-80d6-d24b6718a5c6'
      uri = "#{HOST}/routing_forms/#{uuid}"
      assert_equal(uuid, RoutingForm.extract_uuid(uri))
    end
  end
end
