# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::OrganizationMembership
  class OrganizationMembershipTest < BaseTest
    def setup
      super
      @mem_uuid = 'MEM001'
      @mem_uri = "#{HOST}/organization_memberships/#{@mem_uuid}"
      attrs = { uri: @mem_uri }
      @mem = OrganizationMembership.new attrs, @client
      @mem_no_client = OrganizationMembership.new attrs
    end

    def test_that_it_returns_an_error_client_is_not_ready
      proc_client_is_blank = proc do
        @mem_no_client.fetch
      end
      assert_error proc_client_is_blank, '@client is not ready.'
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
  end
end
