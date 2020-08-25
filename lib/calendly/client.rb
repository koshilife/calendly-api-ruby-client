# frozen_string_literal: true

require 'oauth2'

module Calendly
  # Calendly apis client.
  class Client
    API_HOST = 'https://api.calendly.com'
    AUTH_API_HOST = 'https://auth.calendly.com'

    # @param [String] token a Calendly's access token.
    def initialize(token = nil)
      @config = Calendly.configuration
      @logger = @config.logger
      @token = token || Calendly.configuration.token

      check_not_empty @token, 'token'
      check_token
    end

    #
    # Get access token object.
    #
    # @return [OAuth2::AccessToken]
    # @since 0.0.1
    def access_token
      return @access_token if defined? @access_token

      client = OAuth2::Client.new(@config.client_id,
                                  @config.client_secret, client_options)
      @access_token = OAuth2::AccessToken.new(
        client, @token,
        refresh_token: @config.refresh_token,
        expires_at: @config.token_expires_at
      )
    end

    #
    # Refresh access token.
    #
    # @raise [Calendly::Error] if the client_id is empty.
    # @raise [Calendly::Error] if the client_secret is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.7
    def refresh!
      check_not_empty @config.client_id, 'client_id'
      check_not_empty @config.client_secret, 'client_secret'
      @access_token = access_token.refresh!
    rescue OAuth2::Error => e
      res = e.response.response
      raise ApiError.new res, e
    end

    #
    # Get basic information about current user.
    #
    # @return [Calendly::User]
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.1
    def current_user
      user
    end

    alias me current_user

    #
    # Get basic information about a user
    #
    # @param [String] uuid User unique identifier, or the constant "me" to reference the caller
    # @return [Calendly::User]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.1
    def user(uuid = 'me')
      check_not_empty uuid, 'uuid'
      body = request :get, "users/#{uuid}"
      User.new body[:resource], self
    end

    #
    # Returns all Event Types associated with a specified User.
    #
    # @param [String] user_uri the specified user (user's uri).
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @option opts [String] :sort Order results by the specified field and direction. Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Array<Calendly::EventType>, Hash>]
    #  - [Array<Calendly::EventType>] event_types
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the user_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.2
    def event_types(user_uri, opts = {})
      check_not_empty user_uri, 'user_uri'

      opts_keys = %i[count page_token sort]
      params = { user: user_uri }
      params = merge_options opts, opts_keys, params
      body = request :get, 'event_types', params: params

      items = body[:collection] || []
      ev_types = items.map { |item| EventType.new item, self }
      [ev_types, next_page_params(body)]
    end

    #
    # Returns a single Event by its URI.
    #
    # @param [String] uuid the specified event (event's uuid).
    # @return [Calendly::Event]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.3
    def scheduled_event(uuid)
      check_not_empty uuid, 'uuid'
      body = request :get, "scheduled_events/#{uuid}"
      Event.new body[:resource], self
    end

    #
    # Get List of User Events.
    #
    # @param [String] user_uri the specified user (user's uri).
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :invitee_email Return events scheduled with the specified invitee email
    # @option opts [String] :max_start_time Upper bound (inclusive) for an event's start time to filter by.
    # @option opts [String] :min_start_time Lower bound (inclusive) for an event's start time to filter by.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @option opts [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # @option opts [String] :status Whether the scheduled event is active or canceled
    # @return [Array<Array<Calendly::Event>, Hash>]
    #  - [Array<Calendly::Event>] events
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the user_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.3
    def scheduled_events(user_uri, opts = {})
      check_not_empty user_uri, 'user_uri'

      opts_keys = %i[count invitee_email max_start_time min_start_time page_token sort status]
      params = { user: user_uri }
      params = merge_options opts, opts_keys, params
      body = request :get, 'scheduled_events', params: params

      items = body[:collection] || []
      evs = items.map { |item| Event.new item, self }
      [evs, next_page_params(body)]
    end

    #
    # Get Invitee of an Event
    # Returns a single Invitee by their URI.
    #
    # @param [String] ev_uuid the specified event (event's uuid).
    # @param [String] inv_uuid the specified invitee (invitee's uuid).
    # @return [Calendly::Invitee]
    # @raise [Calendly::Error] if the ev_uuid arg is empty.
    # @raise [Calendly::Error] if the inv_uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.4
    def event_invitee(ev_uuid, inv_uuid)
      check_not_empty ev_uuid, 'ev_uuid'
      check_not_empty inv_uuid, 'inv_uuid'
      body = request :get, "scheduled_events/#{ev_uuid}/invitees/#{inv_uuid}"
      Invitee.new body[:resource], self
    end

    #
    # Get List of Event Invitees.
    #
    # @param [String] uuid the specified event (event's uuid).
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :email Filter by email.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @option opts [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # @option opts [String] :status Whether the scheduled event is active or canceled.
    # @return [Array<Array<Calendly::Invitee>, Hash>]
    #  - [Array<Calendly::Invitee>] invitees
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.4
    def event_invitees(uuid, opts = {})
      check_not_empty uuid, 'uuid'

      opts_keys = %i[count email page_token sort status]
      params = merge_options opts, opts_keys
      body = request :get, "scheduled_events/#{uuid}/invitees", params: params

      items = body[:collection] || []
      evs = items.map { |item| Invitee.new item, self }
      [evs, next_page_params(body)]
    end

    #
    # Returns information about a user's organization membership
    #
    # @param [String] uuid the specified membership (organization membership's uuid).
    # @return [Calendly::OrganizationMembership]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.5
    def membership(uuid)
      check_not_empty uuid, 'uuid'
      body = request :get, "organization_memberships/#{uuid}"
      OrganizationMembership.new body[:resource], self
    end

    #
    # Get List memberships of all users belonging to an organization.
    #
    # @param [String] org_uri the specified organization (organization's uri).
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :email Filter by email.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @return [Array<Array<Calendly::OrganizationMembership>, Hash>]
    #  - [Array<Calendly::OrganizationMembership>] memberships
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the org_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.5
    def memberships(org_uri, opts = {})
      check_not_empty org_uri, 'org_uri'

      opts_keys = %i[count email page_token]
      params = { organization: org_uri }
      params = merge_options opts, opts_keys, params
      body = request :get, 'organization_memberships', params: params

      items = body[:collection] || []
      memberships = items.map { |item| OrganizationMembership.new item, self }
      [memberships, next_page_params(body)]
    end

    #
    # Get List memberships of all users belonging to an organization by user.
    #
    # @param [String] user_uri the specified user (user's uri).
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :email Filter by email.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @return [Array<Array<Calendly::OrganizationMembership>, Hash>]
    #  - [Array<Calendly::OrganizationMembership>] memberships
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the user_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.5
    def memberships_by_user(user_uri, opts = {})
      check_not_empty user_uri, 'user_uri'

      opts_keys = %i[count email page_token]
      params = { user: user_uri }
      params = merge_options opts, opts_keys, params
      body = request :get, 'organization_memberships', params: params

      items = body[:collection] || []
      memberships = items.map { |item| OrganizationMembership.new item, self }
      [memberships, next_page_params(body)]
    end

    #
    # Remove a User from an Organization.
    #
    # @param [String] uuid the specified memberhip (organization memberhips's uuid).
    # @return [true]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.7
    def delete_membership(uuid)
      check_not_empty uuid, 'uuid'
      request :delete, "organization_memberships/#{uuid}", expected_status: 204
      true
    end

    #
    # Returns an Organization Invitation.
    #
    # @param [String] org_uuid the specified organization (organization's uri).
    # @param [String] inv_uuid the specified invitation (organization invitation's uri).
    # @return [Calendly::OrganizationInvitation]
    # @raise [Calendly::Error] if the org_uuid arg is empty.
    # @raise [Calendly::Error] if the inv_uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.6
    def invitation(org_uuid, inv_uuid)
      check_not_empty org_uuid, 'org_uuid'
      check_not_empty inv_uuid, 'inv_uuid'

      body = request :get, "organizations/#{org_uuid}/invitations/#{inv_uuid}"
      OrganizationInvitation.new body[:resource], self
    end

    #
    # Get Organization Invitations.
    #
    # @param [String] uuid the specified organization (organization's uri).
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :email Filter by email.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @option opts [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # @option opts [String] :status Filter by status.
    # @return [<Array<Array<Calendly::OrganizationInvitation>, Hash>]
    #  - [Array<Calendly::OrganizationInvitation>] organizations
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.6
    def invitations(uuid, opts = {})
      check_not_empty uuid, 'uuid'

      opts_keys = %i[count email page_token sort status]
      params = merge_options opts, opts_keys

      body = request :get, "organizations/#{uuid}/invitations", params: params
      items = body[:collection] || []
      evs = items.map { |item| OrganizationInvitation.new item, self }
      [evs, next_page_params(body)]
    end

    #
    # Invite a person to an Organization.
    #
    # @param [String] uuid the specified organization (organization's uri).
    # @param [String] email Email of the person being invited.
    # @return [Calendly::OrganizationInvitation]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::Error] if the email arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.7
    def create_invitation(uuid, email)
      check_not_empty uuid, 'uuid'
      check_not_empty email, 'email'
      body = request(
        :post,
        "organizations/#{uuid}/invitations",
        body: { email: email },
        expected_status: 201
      )
      OrganizationInvitation.new body[:resource], self
    end

    #
    # Revoke Organization Invitation.
    #
    # @param [String] org_uuid the specified organization (organization's uri).
    # @param [String] inv_uuid the specified invitation (organization invitation's uri).
    # @return [true]
    # @raise [Calendly::Error] if the org_uuid arg is empty.
    # @raise [Calendly::Error] if the inv_uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.7
    def delete_invitation(org_uuid, inv_uuid)
      check_not_empty org_uuid, 'org_uuid'
      check_not_empty inv_uuid, 'inv_uuid'
      request(
        :delete,
        "organizations/#{org_uuid}/invitations/#{inv_uuid}",
        expected_status: 204
      )
      true
    end

    private

    def debug_log(msg)
      return unless @logger

      @logger.debug msg
    end

    def request(method, path, params: nil, body: nil, expected_status: nil)
      debug_log "Request #{method.to_s.upcase} #{API_HOST}/#{path} params:#{params}, body:#{body}"
      res = access_token.request(method, path, params: params, body: body)
      debug_log "Response status:#{res.status}, body:#{res.body}"
      validate_status_code res, expected_status
      parse_as_json res
    rescue OAuth2::Error => e
      res = e.response.response
      raise ApiError.new res, e
    end

    def validate_status_code(res, expected_status)
      return unless expected_status
      return if expected_status == res.status

      raise ApiError.new res, message: 'unexpected http status returned.'
    end

    def parse_as_json(res)
      return if blank? res.body

      JSON.parse res.body, symbolize_names: true
    rescue JSON::ParserError => e
      raise ApiError.new res, e
    end

    def check_not_empty(value, name)
      raise Calendly::Error, "#{name} is required." if blank? value
    end

    def blank?(value)
      return true if value.nil?
      return true if value.to_s.empty?

      false
    end

    def check_token
      refresh! if access_token.expired?
    end

    def client_options
      {
        site: API_HOST,
        authorize_url: "#{AUTH_API_HOST}/oauth/authorize",
        token_url: "#{AUTH_API_HOST}/oauth/token"
      }
    end

    def merge_options(opts, filters, params = {})
      return params unless opts.is_a? Hash

      permitted_opts = opts.transform_keys(&:to_sym).slice(*filters)
      params.merge permitted_opts
    end

    def next_page_params(body)
      return unless body[:pagination]
      return unless body[:pagination][:next_page]

      uri = URI.parse body[:pagination][:next_page]
      params = Hash[URI.decode_www_form(uri.query)]
      params.transform_keys(&:to_sym)
    end
  end
end
