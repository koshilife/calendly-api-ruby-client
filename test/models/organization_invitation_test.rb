# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::OrganizationInvitation
  class OrganizationInvitationTest < BaseTest
    def setup
      super
      org_uuid = 'ORG001'
      org_uri = "#{HOST}/organizations/#{org_uuid}"
      @inv_uuid = 'INV001'
      @inv_uri = "#{org_uri}/invitations/#{@inv_uuid}"
      attrs = { uri: @inv_uri, organization: org_uri }
      @inv = OrganizationInvitation.new attrs, @client
      @inv_no_client = OrganizationInvitation.new attrs
    end

    def test_that_it_returns_an_error_client_is_not_ready
      proc_client_is_blank = proc do
        @inv_no_client.fetch
      end
      assert_error proc_client_is_blank, '@client is not ready.'
    end

    def test_that_it_returns_an_associated_invitation
      res_body = load_test_data 'organization_invitation_001.json'
      add_stub_request :get, @inv_uri, res_body: res_body
      assert_org_inv001 @inv.fetch
    end

    def test_that_it_deletes_self
      add_stub_request :delete, @inv_uri, res_status: 204
      result = @inv.delete
      assert_equal true, result
    end
  end
end
