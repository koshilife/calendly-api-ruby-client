# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::Client
  class ClientTest < BaseTest
    #
    # test for initialize
    #

    def test_that_it_returns_token_empty_error
      proc_generate_client = proc do
        Calendly::Client.new
      end
      assert_required_error proc_generate_client, 'token'
    end

    def test_that_it_configure_client
      init_configuration
      config = Calendly.configuration
      assert_equal @client_id, config.client_id
      assert_equal @client_secret, config.client_secret
      assert_equal @token, config.token
      assert_equal @refresh_token, config.refresh_token
      assert_equal @expires_at, config.token_expires_at
      assert_equal @my_logger, config.logger
      Calendly::Client.new
    end

    def test_that_it_log
      @client.debug_log 'test_debug'
      @client.info_log 'test_info'
      @client.warn_log 'test_warn'
      @client.error_log 'test_error'
    end

    #
    # refresh!
    #

    def test_that_it_exchanges_new_access_token
      init_configuration
      add_refresh_token_stub_request
      client = Calendly::Client.new
      new_token = client.refresh!
      assert_equal 'NEW_TOKEN', new_token.token
      assert_equal 'NEW_REFRESH_TOKEN', new_token.refresh_token
    end

    def test_that_it_raises_an_argument_error_on_refresh!
      proc_refresh = proc do
        @client.refresh!
      end
      assert_required_error proc_refresh, 'client_id'
      Calendly.configuration.client_id = @client_id
      assert_required_error proc_refresh, 'client_secret'
    end

    def test_that_it_returns_an_invalid_token_error_on_initialize
      is_expired = true
      init_configuration(is_expired)
      is_valid = false
      add_refresh_token_stub_request(is_valid)
      proc_invalid_grant = proc do
        Calendly::Client.new
      end
      assert_400_invalid_grant proc_invalid_grant
    end

    #
    # test for current_user
    #

    def test_that_it_returns_a_current_user
      res_body = load_test_data 'user_001.json'
      add_stub_request :get, "#{HOST}/users/me", res_body: res_body

      assert_user001 @client.current_user
      assert_user001 @client.me
    end

    #
    # test for user
    #

    def test_that_it_returns_a_specific_user
      res_body = load_test_data 'user_001.json'
      add_stub_request :get, "#{HOST}/users/U001", res_body: res_body

      user = @client.user 'U001'
      assert_user001 user
    end

    def test_that_it_raises_an_argument_error_on_user
      proc_arg_is_nil = proc do
        @client.user nil
      end
      proc_arg_is_empty = proc do
        @client.user ''
      end
      assert_required_error proc_arg_is_nil, 'uuid'
      assert_required_error proc_arg_is_empty, 'uuid'
    end

    #
    # test for event_types
    #

    def test_that_it_returns_all_items_of_event_type
      user_uri = 'https://api.calendly.com/users/U001'
      res_body = load_test_data 'event_types_001.json'
      params = { user: user_uri }

      url = "#{HOST}/event_types?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      event_types, next_params = @client.event_types user_uri
      assert_equal 3, event_types.length
      assert_nil next_params
      assert_event_type001 event_types[0]
      assert_event_type002 event_types[1]
      assert_event_type003 event_types[2]
    end

    def test_that_it_returns_all_items_of_event_type_by_pagination
      user_uri = 'https://api.calendly.com/users/U001'

      res_body1 = load_test_data 'event_types_002_page1.json'
      option_params1 = { count: 2, sort: 'created_at:desc' }
      params1 = { user: user_uri }.merge option_params1
      url1 = "#{HOST}/event_types?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'event_types_002_page2.json'
      option_params2 = { count: 2, page_token: 'NEXT_PAGE_TOKEN' }
      params2 = { user: user_uri }.merge option_params2
      url2 = "#{HOST}/event_types?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      event_types_page1, next_params1 = @client.event_types user_uri, option_params1
      user_uri_page1 = next_params1.delete :user
      # request page2
      event_types_page2, next_params2 = @client.event_types user_uri_page1, next_params1

      assert_equal 2, event_types_page1.length
      assert_equal 1, event_types_page2.length
      assert_nil next_params2
      assert_event_type003 event_types_page1[0]
      assert_event_type002 event_types_page1[1]
      assert_event_type001 event_types_page2[0]
    end

    def test_that_it_raises_an_argument_error_on_event_types
      proc_arg_is_empty = proc do
        @client.event_types ''
      end
      assert_required_error proc_arg_is_empty, 'user_uri'
    end

    #
    # test for scheduled_event
    #

    def test_that_it_returns_a_specific_event
      ev_uuid = 'EV001'
      res_body = load_test_data 'scheduled_event_001.json'

      url = "#{HOST}/scheduled_events/#{ev_uuid}"
      add_stub_request :get, url, res_body: res_body

      ev = @client.scheduled_event ev_uuid
      assert_event001 ev
    end

    def test_that_it_raises_an_argument_error_on_event
      proc_arg_is_empty = proc do
        @client.scheduled_event ''
      end
      assert_required_error proc_arg_is_empty, 'uuid'
    end

    #
    # test for scheduled_events
    #

    def test_that_it_returns_all_items_of_event
      user_uri = 'https://api.calendly.com/users/U001'
      res_body = load_test_data 'scheduled_events_001.json'
      params = { user: user_uri }

      url = "#{HOST}/scheduled_events?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      evs, next_params = @client.scheduled_events user_uri
      assert_equal 2, evs.length
      assert_nil next_params
      assert_event001 evs[0]
      assert_event002 evs[1]
    end

    def test_that_it_returns_all_items_of_event_by_pagination
      user_uri = 'https://api.calendly.com/users/U001'
      base_params = {
        count: 2,
        invitee_email: 'foobar@example.com',
        max_start_time: '2020-08-01T00:00:00.000000Z',
        min_start_time: '2020-07-01T00:00:00.000000Z',
        user: user_uri,
        status: 'active'
      }
      res_body1 = load_test_data 'scheduled_events_002_page1.json'
      params1 = base_params.merge(
        sort: 'start_time:desc'
      )
      url1 = "#{HOST}/scheduled_events?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'scheduled_events_002_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/scheduled_events?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      evs_page1, next_params1 = @client.scheduled_events user_uri, params1
      user_uri = next_params1.delete :user
      # request page2
      evs_page2, next_params2 = @client.scheduled_events user_uri, next_params1

      assert_equal 2, evs_page1.length
      assert_equal 1, evs_page2.length
      assert_nil next_params2
      assert_event003 evs_page1[0]
      assert_event002 evs_page1[1]
      assert_event001 evs_page2[0]
    end

    def test_that_it_raises_an_argument_error_on_events
      proc_arg_is_empty = proc do
        @client.scheduled_events ''
      end
      assert_required_error proc_arg_is_empty, 'user_uri'
    end

    #
    # test for event_invitee
    #

    def test_that_it_returns_a_one_on_one_event_invitee
      ev_uuid = 'EV101'
      inv_uuid = 'INV001'
      res_body = load_test_data 'scheduled_event_invitee_101.json'

      url = "#{HOST}/scheduled_events/#{ev_uuid}/invitees/#{inv_uuid}"
      add_stub_request :get, url, res_body: res_body

      inv = @client.event_invitee ev_uuid, inv_uuid
      assert_event101_invitee001 inv
    end

    def test_that_it_raises_an_argument_error_on_event_invitee
      proc_ev_uuid_arg_is_empty = proc do
        @client.event_invitee '', 'INV001'
      end
      proc_inv_uuid_arg_is_empty = proc do
        @client.event_invitee 'EV001', ''
      end
      assert_required_error proc_ev_uuid_arg_is_empty, 'ev_uuid'
      assert_required_error proc_inv_uuid_arg_is_empty, 'inv_uuid'
    end

    #
    # test for event_invitees
    #

    def test_that_it_returns_one_on_one_event_invitees
      ev_uuid = 'EV001'
      res_body = load_test_data 'scheduled_event_invitees_101.json'

      url = "#{HOST}/scheduled_events/#{ev_uuid}/invitees"
      add_stub_request :get, url, res_body: res_body

      invs, next_params = @client.event_invitees ev_uuid
      assert_equal 1, invs.length
      assert_nil next_params
      assert_event101_invitee001 invs[0]
    end

    def test_that_it_returns_group_event_invitees
      ev_uuid = 'EV201'
      base_params = {
        count: 2,
        email: 'foobar@example.com',
        status: 'active'
      }

      res_body1 = load_test_data 'scheduled_event_invitees_201_page1.json'
      params1 = base_params.merge(
        sort: 'created_at:desc'
      )
      url1 = "#{HOST}/scheduled_events/#{ev_uuid}/invitees?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'scheduled_event_invitees_201_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/scheduled_events/#{ev_uuid}/invitees?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      invs_page1, next_params1 = @client.event_invitees ev_uuid, params1
      # request page2
      invs_page2, next_params2 = @client.event_invitees ev_uuid, next_params1

      assert_equal 2, invs_page1.length
      assert_equal 1, invs_page2.length
      assert_nil next_params2
      assert_event201_invitee003 invs_page1[0]
      assert_event201_invitee002 invs_page1[1]
      assert_event201_invitee001 invs_page2[0]
    end

    def test_that_it_raises_an_argument_error_on_event_invitees
      proc_arg_is_empty = proc do
        @client.event_invitees ''
      end
      assert_required_error proc_arg_is_empty, 'uuid'
    end

    #
    # test for membership
    #

    def test_that_it_returns_a_specific_membership
      mem_uuid = 'MEM001'
      res_body = load_test_data 'organization_membership_001.json'
      url = "#{HOST}/organization_memberships/#{mem_uuid}"
      add_stub_request :get, url, res_body: res_body

      mem = @client.membership mem_uuid
      assert_org_mem001 mem
    end

    def test_that_it_raises_an_argument_error_on_membership
      proc_arg_is_empty = proc do
        @client.membership ''
      end
      assert_required_error proc_arg_is_empty, 'uuid'
    end

    #
    # test for memberships
    #

    def test_that_it_returns_all_memberships_by_pagination
      org_uri = 'https://api.calendly.com/organizations/ORG001'
      base_params = {
        organization: org_uri,
        count: 2
      }

      params1 = base_params.dup
      res_body1 = load_test_data 'organization_memberships_002_page1.json'
      url1 = "#{HOST}/organization_memberships?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'organization_memberships_002_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/organization_memberships?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      mems_page1, next_params1 = @client.memberships org_uri, params1
      org_uri = next_params1.delete(:organization)
      # request page2
      mems_page2, next_params2 = @client.memberships org_uri, next_params1

      assert_equal 2, mems_page1.length
      assert_equal 1, mems_page2.length
      assert_nil next_params2
      assert_org_mem001 mems_page1[0]
      assert_org_mem002 mems_page1[1]
      assert_org_mem003 mems_page2[0]
    end

    def test_that_it_raises_an_argument_error_on_memberships
      proc_arg_is_empty = proc do
        @client.memberships ''
      end
      assert_required_error proc_arg_is_empty, 'org_uri'
    end

    #
    # test for memberships_by_user
    #

    def test_that_it_returns_memberships_specific_user
      user_uri = 'https://api.calendly.com/users/U101'
      res_body = load_test_data 'organization_memberships_001.json'

      params = { user: user_uri }
      url = "#{HOST}/organization_memberships?#{URI.encode_www_form(params)}"
      add_stub_request :get, url, res_body: res_body

      mems, next_params = @client.memberships_by_user user_uri
      assert_equal 1, mems.length
      assert_nil next_params
      assert_org_mem001 mems[0]
    end

    def test_that_it_raises_an_argument_error_on_memberships_by_user
      proc_arg_is_empty = proc do
        @client.memberships_by_user ''
      end
      assert_required_error proc_arg_is_empty, 'user_uri'
    end

    #
    # test for delete_membership
    #

    def test_that_it_deletes_an_exists_membership
      uuid = 'MEM001'
      url = "#{HOST}/organization_memberships/#{uuid}"
      add_stub_request :delete, url, res_status: 204

      result = @client.delete_membership uuid
      assert_equal true, result
    end

    def test_that_it_raises_an_argument_error_on_delete_membership
      proc_arg_is_empty = proc do
        @client.delete_membership ''
      end
      assert_required_error proc_arg_is_empty, 'uuid'
    end

    #
    # test for invitation
    #

    def test_that_it_returns_a_specific_invitation
      org_uuid = 'ORG001'
      inv_uuid = 'INV001'
      res_body = load_test_data 'organization_invitation_001.json'
      url = "#{HOST}/organizations/#{org_uuid}/invitations/#{inv_uuid}"
      add_stub_request :get, url, res_body: res_body

      inv = @client.invitation org_uuid, inv_uuid
      assert_org_inv001 inv
    end

    def test_that_it_raises_an_argument_error_on_invitation
      proc_org_uuid_arg_is_empty = proc do
        @client.invitation '', 'INV001'
      end
      proc_inv_uuid_arg_is_empty = proc do
        @client.invitation 'ORG001', ''
      end
      assert_required_error proc_org_uuid_arg_is_empty, 'org_uuid'
      assert_required_error proc_inv_uuid_arg_is_empty, 'inv_uuid'
    end

    #
    # test for invitations
    #

    def test_that_it_returns_all_organization_invitations
      org_uuid = 'ORG001'
      res_body = load_test_data 'organization_invitations_001.json'
      url = "#{HOST}/organizations/#{org_uuid}/invitations"
      add_stub_request :get, url, res_body: res_body

      invs, next_params = @client.invitations org_uuid
      assert_equal 3, invs.length
      assert_nil next_params
      assert_org_inv001 invs[0]
      assert_org_inv002 invs[1]
      assert_org_inv003 invs[2]
    end

    def test_that_it_returns_all_organization_invitations_by_pagination
      org_uuid = 'ORG001'
      base_params = { count: 2 }

      params1 = base_params.merge(sort: 'created_at:desc')
      res_body1 = load_test_data 'organization_invitations_002_page1.json'
      url1 = "#{HOST}/organizations/#{org_uuid}/invitations?#{URI.encode_www_form(params1)}"
      add_stub_request :get, url1, res_body: res_body1

      res_body2 = load_test_data 'organization_invitations_002_page2.json'
      params2 = base_params.merge(
        page_token: 'NEXT_PAGE_TOKEN'
      )
      url2 = "#{HOST}/organizations/#{org_uuid}/invitations?#{URI.encode_www_form(params2)}"
      add_stub_request :get, url2, res_body: res_body2

      # request page1
      invs_page1, next_params1 = @client.invitations org_uuid, params1
      # request page2
      invs_page2, next_params2 = @client.invitations org_uuid, next_params1

      assert_equal 2, invs_page1.length
      assert_equal 1, invs_page2.length
      assert_nil next_params2
      assert_org_inv003 invs_page1[0]
      assert_org_inv002 invs_page1[1]
      assert_org_inv001 invs_page2[0]
    end

    def test_that_it_raises_an_argument_error_on_invitations
      proc_arg_is_empty = proc do
        @client.invitations ''
      end
      assert_required_error proc_arg_is_empty, 'uuid'
    end

    #
    # test for create_invitation
    #

    def test_that_it_creates_invitation
      org_uuid = 'ORG001'
      email = 'foobar@example.com'
      req_body = { email: email }
      res_body = load_test_data 'organization_invitation_003_create.json'
      url = "#{HOST}/organizations/#{org_uuid}/invitations"
      add_stub_request :post, url, req_body: req_body, res_body: res_body, res_status: 201

      inv = @client.create_invitation org_uuid, email
      assert_org_inv003 inv
    end

    def test_that_it_raises_an_argument_error_on_create_invitation
      proc_uuid_arg_is_empty = proc do
        @client.create_invitation '', 'foobar@example.com'
      end
      proc_email_arg_is_empty = proc do
        @client.create_invitation 'ORG001', ''
      end
      assert_required_error proc_uuid_arg_is_empty, 'uuid'
      assert_required_error proc_email_arg_is_empty, 'email'
    end

    #
    # test for delete_invitation
    #

    def test_that_it_deletes_invitation
      org_uuid = 'ORG001'
      inv_uuid = 'INV001'
      url = "#{HOST}/organizations/#{org_uuid}/invitations/#{inv_uuid}"
      add_stub_request :delete, url, res_status: 204

      result = @client.delete_invitation org_uuid, inv_uuid
      assert_equal true, result
    end

    def test_that_it_raises_an_argument_error_on_delete_invitation
      proc_org_uuid_arg_is_empty = proc do
        @client.delete_invitation '', 'INV001'
      end
      proc_inv_uuid_arg_is_empty = proc do
        @client.delete_invitation 'ORG001', ''
      end
      assert_required_error proc_org_uuid_arg_is_empty, 'org_uuid'
      assert_required_error proc_inv_uuid_arg_is_empty, 'inv_uuid'
    end

    #
    # Following tests are handling to an api error.
    #

    def test_that_it_raises_an_api_error_if_ng_status_is_returned
      not_exist_user_id = 'NOT_EXSIT_USER'
      res_body = load_test_data 'error_404_not_found.json'
      url = "#{HOST}/users/#{not_exist_user_id}"
      add_stub_request :get, url, res_body: res_body, res_status: 404

      proc_404_error = proc do
        @client.user not_exist_user_id
      end
      assert_404_error proc_404_error
    end

    def test_that_it_raises_an_api_error_if_ok_status_not_json_is_returned
      user_id = 'U001'
      res_body = load_test_data 'not_json.html'
      url = "#{HOST}/users/#{user_id}"
      add_stub_request :get, url, res_body: res_body, res_status: 200

      proc_error = proc do
        @client.user user_id
      end
      assert_api_error proc_error, 200, res_body
    end

    def test_that_it_raises_an_api_error_if_ng_status_not_json_is_returned
      user_id = 'U001'
      res_body = load_test_data 'not_json.html'
      url = "#{HOST}/users/#{user_id}"
      add_stub_request :get, url, res_body: res_body, res_status: 400

      proc_error = proc do
        @client.user user_id
      end
      assert_api_error proc_error, 400, res_body
    end

    private

    def add_refresh_token_stub_request(is_valid = true)
      req_params = {
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: 'refresh_token',
        refresh_token: @refresh_token
      }
      req_body = URI.encode_www_form(req_params)
      if is_valid
        res_status = 200
        res_body = load_test_data 'refresh_token.json'
      else
        res_status = 400
        res_body = load_test_data 'error_400_invalid_grant.json'
      end
      url = "#{Calendly::Client::AUTH_API_HOST}/oauth/token"
      stub_request(:post, url).with(body: req_body).to_return(status: res_status, body: res_body, headers: default_response_headers)
    end
  end
end
