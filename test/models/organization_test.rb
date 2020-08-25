# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::Organization
  class OrganizationTest < BaseTest
    def setup
      super
      @org_uuid = 'ORG001'
      @org_uri = "#{HOST}/organizations/#{@org_uuid}"
      @org_params = { organization: @org_uri }
      attrs = { uri: @org_uri }
      @org = Organization.new attrs, @client
      @org_no_client = Organization.new attrs
    end

    def test_that_it_returns_an_error_client_is_not_ready
      proc_client_is_blank = proc do
        @org_no_client.memberships
      end
      assert_error proc_client_is_blank, '@client is not ready.'
    end

    def test_that_it_returns_memberships_in_single_page
      res_body = load_test_data 'organization_memberships_001.json'
      url = "#{HOST}/organization_memberships?#{URI.encode_www_form(@org_params)}"
      add_stub_request :get, url, res_body: res_body

      mems = @org.memberships
      assert_equal 1, mems.length
      assert_org_mem001 mems[0]
    end

    def test_that_it_returns_memberships_in_plurality_of_pages
      params1 = @org_params.merge(count: 2)
      res_body1 = load_test_data 'organization_memberships_002_page1.json'
      url1 = "#{HOST}/organization_memberships?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      params2 = params1.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      res_body2 = load_test_data 'organization_memberships_002_page2.json'
      url2 = "#{HOST}/organization_memberships?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      mems = @org.memberships params1
      assert_equal 3, mems.length
      assert_org_mem001 mems[0]
      assert_org_mem002 mems[1]
      assert_org_mem003 mems[2]
    end

    def test_that_it_returns_invitations_in_single_page
      res_body = load_test_data 'organization_invitations_001.json'
      url = "#{@org_uri}/invitations"
      add_stub_request :get, url, res_body: res_body

      invs = @org.invitations
      assert_equal 3, invs.length
      assert_org_inv001 invs[0]
      assert_org_inv002 invs[1]
      assert_org_inv003 invs[2]
    end

    def test_that_it_returns_invitations_in_plurality_of_pages
      base_params = { count: 2 }
      params1 = base_params.merge(sort: 'created_at:desc')
      res_body1 = load_test_data 'organization_invitations_002_page1.json'
      url1 = "#{@org_uri}/invitations?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      res_body2 = load_test_data 'organization_invitations_002_page2.json'
      url2 = "#{@org_uri}/invitations?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      invs = @org.invitations params1
      assert_equal 3, invs.length
      assert_org_inv003 invs[0]
      assert_org_inv002 invs[1]
      assert_org_inv001 invs[2]
    end

    def test_that_it_creates_invitation
      email = 'foobar@example.com'
      req_body = { email: email }
      res_body = load_test_data 'organization_invitation_003_create.json'
      url = "#{@org_uri}/invitations"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      inv = @org.create_invitation email
      assert_org_inv003 inv
    end
  end
end
