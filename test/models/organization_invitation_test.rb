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
      attrs = {uri: @inv_uri, organization: org_uri}
      @inv = OrganizationInvitation.new attrs, @client
    end

    def test_it_returns_inspect_string
      assert @inv.inspect.start_with? '#<Calendly::OrganizationInvitation:'
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

    def test_that_it_parses_uuid_be_formatted_ascii_from_uri
      org_uuid = '6dc5fbc7-fd4f-4680-af7d-2b4ec6f25748'
      uuid = '495cdb33-7357-47ef-b69f-0f70a521f72d'
      uri = "#{HOST}/organizations/#{org_uuid}/invitations/#{uuid}"
      assert_equal(uuid, OrganizationInvitation.extract_uuid(uri))
    end
  end
end
