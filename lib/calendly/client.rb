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
      return @access_token if defined?(@access_token)

      client = OAuth2::Client.new(@config.client_id,
                                  @config.client_secret, client_options)
      @access_token = OAuth2::AccessToken.new(
        client, @token,
        refresh_token: @config.refresh_token,
        expires_at: @config.token_expires_at
      )
    end

    #
    # Get basic information about current user.
    #
    # @return [Calendly::User]
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
    # @since 0.0.1
    def user(uuid = 'me')
      check_not_empty uuid, 'uuid'
      body = request :get, "users/#{uuid}"
      User.new body[:resource]
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
    # @since 0.0.2
    def event_types(user_uri, opts = {})
      check_not_empty user_uri, 'user_uri'

      opts_keys = %i[count page_token sort]
      params = { user: user_uri }
      params = merge_options opts, opts_keys, params
      body = request :get, 'event_types', params

      items = body[:collection] || []
      ev_types = items.map { |item| EventType.new item }
      [ev_types, next_page_params(body)]
    end

    #
    # Returns a single Event by its URI.
    #
    # @param [String] uuid the specified scheduled event (event's uuid).
    # @return [Calendly::Event]
    # @since 0.0.3
    def event(uuid)
      check_not_empty uuid, 'uuid'
      body = request :get, "scheduled_events/#{uuid}"
      Event.new body[:resource]
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
    # @since 0.0.3
    def events(user_uri, opts = {})
      check_not_empty user_uri, 'user_uri'

      opts_keys = %i[count invitee_email max_start_time min_start_time page_token sort status]
      params = { user: user_uri }
      params = merge_options opts, opts_keys, params
      body = request :get, 'scheduled_events', params

      items = body[:collection] || []
      evs = items.map { |item| Event.new item }
      [evs, next_page_params(body)]
    end

    #
    # Get Invitee of an Event
    # Returns a single Invitee by their URI.
    #
    # @param [String] ev_uuid the specified scheduled event (event's uuid).
    # @param [String] inv_uuid the specified invitee (invitee's uuid).
    # @return [Calendly::Invitee]
    # @since 0.0.4
    def event_invitee(ev_uuid, inv_uuid)
      check_not_empty ev_uuid, 'ev_uuid'
      check_not_empty inv_uuid, 'inv_uuid'
      body = request :get, "scheduled_events/#{ev_uuid}/invitees/#{inv_uuid}"
      Invitee.new body[:resource]
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
    # @since 0.0.4
    def event_invitees(uuid, opts = {})
      check_not_empty uuid, 'uuid'

      opts_keys = %i[count email page_token sort status]
      params = merge_options opts, opts_keys
      body = request :get, "scheduled_events/#{uuid}/invitees", params

      items = body[:collection] || []
      evs = items.map { |item| Invitee.new item }
      [evs, next_page_params(body)]
    end

    #
    # Returns information about a user's organization membership
    #
    # @param [String] uuid the specified event (organization membership's uuid).
    # @return [OrganizationMembership]
    # @since 0.0.5
    def membership(uuid)
      check_not_empty uuid, 'uuid'
      body = request :get, "organization_memberships/#{uuid}"
      OrganizationMembership.new body[:resource]
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
    # @since 0.0.5
    def memberships(org_uri, opts = {})
      check_not_empty org_uri, 'org_uri'

      opts_keys = %i[count email page_token]
      params = { organization: org_uri }
      params = merge_options opts, opts_keys, params
      body = request :get, 'organization_memberships', params

      items = body[:collection] || []
      memberships = items.map { |item| OrganizationMembership.new item }
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
    # @since 0.0.5
    def memberships_by_user(user_uri, opts = {})
      check_not_empty user_uri, 'user_uri'

      opts_keys = %i[count email page_token]
      params = { user: user_uri }
      params = merge_options opts, opts_keys, params
      body = request :get, 'organization_memberships', params

      items = body[:collection] || []
      memberships = items.map { |item| OrganizationMembership.new item }
      [memberships, next_page_params(body)]
    end

    private

    def request(method, path, params = {})
      debug_log "Request #{method.to_s.upcase} #{API_HOST}/#{path} params:#{params}"
      opts = { params: params }
      res = access_token.request(method, path, opts)
      debug_log "Response status:#{res.status}, body:#{res.body}"
      JSON.parse res.body, symbolize_names: true
    rescue OAuth2::Error => e
      res = e.response.response
      raise ApiError.new res, e
    rescue JSON::ParserError => e
      raise ApiError.new res, e
    end

    def debug_log(msg)
      return if @logger.nil?

      @logger.debug msg
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

    def refresh!
      @access_token = access_token.refresh!
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
