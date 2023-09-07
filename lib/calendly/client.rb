# frozen_string_literal: true

require 'time'
require 'oauth2'
require 'calendly/loggable'

module Calendly
  # Calendly apis client.
  class Client # rubocop:disable Metrics/ClassLength
    include Loggable
    API_HOST = 'https://api.calendly.com'
    AUTH_API_HOST = 'https://auth.calendly.com'

    # @param [String] token a Calendly's access token.
    # @raise [Calendly::Error] if the token is empty.
    def initialize(token = nil)
      @config = Calendly.configuration
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
      return @access_token if defined?(@access_token) && @access_token

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
    # @raise [Calendly::Error] if Calendly.configuration.client_id is empty.
    # @raise [Calendly::Error] if Calendly.configuration.client_secret is empty.
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
      return @cached_current_user if defined?(@cached_current_user) && @cached_current_user

      @cached_current_user = user
    end

    alias me current_user

    # @since 0.2.0
    def current_user!
      @cached_current_user = nil
      current_user
    end

    alias me! current_user!

    #
    # Get basic information about a user
    #
    # @param [String] uuid User unique identifier, or the constant "me" to reference the caller
    # @return [Calendly::User]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.1
    def user(uuid_or_uri = 'me')
      uri = to_request_uri(uuid_or_uri) { |uuid| "users/#{uuid}" }
      body = request :get, uri
      User.new body[:resource], self
    end

    #
    # Returns a single Event Type by its UUID.
    #
    # @param [String] uuid the specified event type (event type's uuid).
    # @return [Calendly::EventType]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.4.1
    def event_type(uuid_or_uri)
      uri = to_request_uri(uuid_or_uri) { |uuid| "event_types/#{uuid}" }
      body = request :get, uri
      EventType.new body[:resource], self
    end

    #
    # Returns all Event Types associated with a specified organization.
    #
    # @param [String] org_uri the specified organization (organization's uri).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Boolean] :active Return only active event types if true, only inactive if false, or all event types if this parameter is omitted.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and direction. Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Array<Calendly::EventType>, Hash>]
    #  - [Array<Calendly::EventType>] event types
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the org_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.6.0
    def event_types(org_uri, options: nil)
      check_not_empty org_uri, 'org_uri'

      opts_keys = %i[active count page_token sort]
      params = {organization: org_uri}
      params = merge_options options, opts_keys, params
      body = request :get, 'event_types', params: params

      items = body[:collection] || []
      ev_types = items.map { |item| EventType.new item, self }
      [ev_types, next_page_params(body)]
    end

    #
    # Returns all Event Types associated with a specified user.
    #
    # @param [String] user_uri the specified user (user's uri).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Boolean] :active Return only active event types if true, only inactive if false, or all event types if this parameter is omitted.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and direction. Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Array<Calendly::EventType>, Hash>]
    #  - [Array<Calendly::EventType>] event types
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the user_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.2
    def event_types_by_user(user_uri, options: nil)
      check_not_empty user_uri, 'user_uri'

      opts_keys = %i[active count page_token sort]
      params = {user: user_uri}
      params = merge_options options, opts_keys, params
      body = request :get, 'event_types', params: params

      items = body[:collection] || []
      ev_types = items.map { |item| EventType.new item, self }
      [ev_types, next_page_params(body)]
    end

    #
    # Returns a list of available times for an event type within a specified date range.
    # Date range can be no greater than 1 week (7 days).
    #
    # @param [String] event_type_uri The uri associated with the event type.
    # @param [String] start_time Start time of the requested availability range.
    # @param [String] end_time End time of the requested availability range.
    # @return [Array<Calendly::EventTypeAvailableTime>] The set of available times for the event type matching the criteria.
    # @raise [Calendly::Error] if the event_type_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.13.0
    def event_type_available_times(event_type_uri, start_time: nil, end_time: nil)
      check_not_empty event_type_uri, 'event_type_uri'

      start_time_buffer = 60 # For working around an invalid request which be caused by specifying a past time
      max_date_range = 60 * 60 * 24 * 7 # 7 days

      # If start_time is undefined, set it to now.
      start_time ||= (Time.now + start_time_buffer).utc.iso8601
      # If end_time is undefined, set it to in the max date range from start_time.
      end_time ||= (Time.parse(start_time) + max_date_range).utc.iso8601

      params = {event_type: event_type_uri, start_time: start_time, end_time: end_time}
      body = request :get, 'event_type_available_times', params: params

      items = body[:collection] || []
      items.map { |item| EventTypeAvailableTime.new item, self }
    end

    #
    # Returns a single Event by its URI.
    #
    # @param [String] uuid the specified event (event's uuid).
    # @return [Calendly::Event]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.3
    def scheduled_event(uuid_or_uri)
      uri = to_request_uri(uuid_or_uri) { |uuid| "scheduled_events/#{uuid}" }
      body = request :get, uri
      Event.new body[:resource], self
    end

    #
    # Get List of scheduled events belonging to a specific organization.
    #
    # @param [String] org_uri the specified organization (organization's uri).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :invitee_email Return events scheduled with the specified invitee email.
    # @option options [String] :max_start_time Upper bound (inclusive) for an event's start time to filter by.
    # @option options [String] :min_start_time Lower bound (inclusive) for an event's start time to filter by.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # @option options [String] :status Whether the scheduled event is active or canceled.
    # @return [Array<Array<Calendly::Event>, Hash>]
    #  - [Array<Calendly::Event>] events
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the org_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.5.0
    def scheduled_events(org_uri, options: nil)
      check_not_empty org_uri, 'org_uri'

      opts_keys = %i[count invitee_email max_start_time min_start_time page_token sort status]
      params = {organization: org_uri}
      params = merge_options options, opts_keys, params
      body = request :get, 'scheduled_events', params: params

      items = body[:collection] || []
      evs = items.map { |item| Event.new item, self }
      [evs, next_page_params(body)]
    end

    #
    # Cancels specified event.
    #
    # @param [String] uuid the event's unique indentifier.
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [String] :reason reason for cancellation.
    # @return [Calendly::InviteeCancellation]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.11.0
    def cancel_event(uuid_or_uri, options: nil)
      uri = to_request_uri(uuid_or_uri) { |uuid| "scheduled_events/#{uuid}/cancellation" }

      opts_keys = %i[reason]
      params = merge_options options, opts_keys

      body = request :post, uri, body: params
      InviteeCancellation.new body[:resource], self
    end

    #
    # Get List of scheduled events belonging to a specific user.
    #
    # @param [String] user_uri the specified user (user's uri).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [String] :organization the specified organization (organization's uri).
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :invitee_email Return events scheduled with the specified invitee email.
    # @option options [String] :max_start_time Upper bound (inclusive) for an event's start time to filter by.
    # @option options [String] :min_start_time Lower bound (inclusive) for an event's start time to filter by.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # @option options [String] :status Whether the scheduled event is active or canceled.
    # @return [Array<Array<Calendly::Event>, Hash>]
    #  - [Array<Calendly::Event>] events
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the user_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.3
    def scheduled_events_by_user(user_uri, options: nil)
      check_not_empty user_uri, 'user_uri'

      opts_keys = %i[organization count invitee_email max_start_time min_start_time page_token sort status]
      params = {user: user_uri}
      params = merge_options options, opts_keys, params
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
    def event_invitee(invitee_uri_or_ev_uuid, inv_uuid = nil)
      check_not_empty invitee_uri_or_ev_uuid, 'invitee_uri_or_ev_uuid'
      uri = to_request_uri(invitee_uri_or_ev_uuid) do |ev_uuid|
        check_not_empty inv_uuid, 'inv_uuid'
        "scheduled_events/#{ev_uuid}/invitees/#{inv_uuid}"
      end
      body = request :get, uri
      Invitee.new body[:resource], self
    end

    #
    # Get List of Event Invitees.
    #
    # @param [String] uuid the specified event (event's uuid).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :email Filter by email.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # @option options [String] :status Whether the scheduled event is active or canceled.
    # @return [Array<Array<Calendly::Invitee>, Hash>]
    #  - [Array<Calendly::Invitee>] invitees
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.4
    def event_invitees(uuid_or_uri, options: nil)
      uri = to_request_uri(uuid_or_uri) { |uuid| "scheduled_events/#{uuid}/invitees" }

      opts_keys = %i[count email page_token sort status]
      params = merge_options options, opts_keys
      body = request :get, uri, params: params

      items = body[:collection] || []
      evs = items.map { |item| Invitee.new item, self }
      [evs, next_page_params(body)]
    end

    #
    # Get Invitee No Show
    # Returns information about a specified Invitee No Show.
    #
    # @param [String] uuid the specified no show.
    # @return [Calendly::InviteeNoShow]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.9.0
    def invitee_no_show(uuid_or_uri)
      uri = to_request_uri(uuid_or_uri) { |uuid| "invitee_no_shows/#{uuid}" }
      body = request :get, uri
      InviteeNoShow.new body[:resource], self
    end

    #
    # Create Invitee No Show
    # Marks an Invitee as a No Show.
    #
    # @param [String] invitee_uri the specified invitee's uri.
    # @return [Calendly::InviteeNoShow]
    # @raise [Calendly::Error] if the invitee_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.9.0
    def create_invitee_no_show(invitee_uri)
      check_not_empty invitee_uri, 'invitee_uri'
      body = request(
        :post,
        'invitee_no_shows',
        body: {invitee: invitee_uri}
      )
      InviteeNoShow.new body[:resource], self
    end

    #
    # Delete Invitee No Show
    # Undoes marking an Invitee as a No Show.
    #
    # @param [String] uuid the specified no show.
    # @return [true]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.9.0
    def delete_invitee_no_show(uuid)
      check_not_empty uuid, 'uuid'
      request :delete, "invitee_no_shows/#{uuid}"
      true
    end

    #
    # Delete Invitee Data
    # To submit a request to remove invitee data from all previously booked events in your organization.
    #
    # @param [Array<String>] emails invitees' emails
    # @return [true]
    # @raise [Calendly::Error] if the emails arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.10.0
    def delete_invitee_data(emails)
      check_not_empty emails, 'emails'
      request(
        :post,
        'data_compliance/deletion/invitees',
        body: {emails: emails}
      )
      true
    end

    #
    # Returns a list of activity log entries.
    #
    # @param [String] org_uri Return activity log entries from the organization associated with this URI.
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Array<String>] :action The action(s) associated with the entries.
    # @option options [Array<String>] :actor Return entries from the user(s) associated with the provided URIs.
    # @option options [Integer] :count The number of rows to return.
    # @option options [String] :max_occurred_at include entries that occurred prior to this time.
    # @option options [String] :min_occurred_at Include entries that occurred after this time.
    # @option options [Array<String>] :namespace The categories of the entries.
    # @option options [String] :page_token The token to pass to get the next portion of the collection.
    # @option options [String] :search_term Filters entries based on the search term.
    # @option options [Array<String>] :sort Order results by the specified field and direction. List of {field}:{direction} values.
    # @return [Array<Array<Calendly::ActivityLogEntry>, Hash, Hash>]
    #  - [Array<Calendly::ActivityLogEntry>] log_entries
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    #  - [Hash] raw_response
    # @raise [Calendly::Error] if the org_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.14.0
    def activity_log_entries(org_uri, options: nil)
      check_not_empty org_uri, 'org_uri'

      opts_keys = %i[action actor count max_occurred_at min_occurred_at namespace page_token search_term sort]
      params = {organization: org_uri}
      params = merge_options options, opts_keys, params
      body = request :get, 'activity_log_entries', params: params

      items = body[:collection] || []
      log_entries = items.map { |item| ActivityLogEntry.new item, self }
      [log_entries, next_page_params(body), body]
    end

    #
    # Returns information about a user's organization membership
    #
    # @param [String] uuid the specified membership (organization membership's uuid).
    # @return [Calendly::OrganizationMembership]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.5
    def membership(uuid_or_uri)
      uri = to_request_uri(uuid_or_uri) { |uuid| "organization_memberships/#{uuid}" }
      body = request :get, uri
      OrganizationMembership.new body[:resource], self
    end

    #
    # Get List of memberships belonging to specific an organization.
    #
    # @param [String] org_uri the specified organization (organization's uri).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :email Filter by email.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @return [Array<Array<Calendly::OrganizationMembership>, Hash>]
    #  - [Array<Calendly::OrganizationMembership>] memberships
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the org_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.5
    def memberships(org_uri, options: nil)
      check_not_empty org_uri, 'org_uri'

      opts_keys = %i[count email page_token]
      params = {organization: org_uri}
      params = merge_options options, opts_keys, params
      body = request :get, 'organization_memberships', params: params

      items = body[:collection] || []
      memberships = items.map { |item| OrganizationMembership.new item, self }
      [memberships, next_page_params(body)]
    end

    #
    # Get List of memberships belonging to specific a user.
    #
    # @param [String] user_uri the specified user (user's uri).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :email Filter by email.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @return [Array<Array<Calendly::OrganizationMembership>, Hash>]
    #  - [Array<Calendly::OrganizationMembership>] memberships
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the user_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.5
    def memberships_by_user(user_uri, options: nil)
      check_not_empty user_uri, 'user_uri'

      opts_keys = %i[count email page_token]
      params = {user: user_uri}
      params = merge_options options, opts_keys, params
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
    def delete_membership(uuid_or_uri)
      uri = to_request_uri(uuid_or_uri) { |uuid| "organization_memberships/#{uuid}" }
      request :delete, uri
      true
    end

    #
    # Returns an Organization Invitation.
    #
    # @param [String] org_uuid the specified organization (organization's uuid).
    # @param [String] inv_uuid the specified invitation (organization invitation's uuid).
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
    # @param [String] uuid the specified organization (organization's uuid).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :email Filter by email.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # @option options [String] :status Filter by status.
    # @return [<Array<Array<Calendly::OrganizationInvitation>, Hash>]
    #  - [Array<Calendly::OrganizationInvitation>] organizations
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.6
    def invitations(uuid, options: nil)
      check_not_empty uuid, 'uuid'

      opts_keys = %i[count email page_token sort status]
      params = merge_options options, opts_keys

      body = request :get, "organizations/#{uuid}/invitations", params: params
      items = body[:collection] || []
      evs = items.map { |item| OrganizationInvitation.new item, self }
      [evs, next_page_params(body)]
    end

    #
    # Invite a person to an Organization.
    #
    # @param [String] uuid the specified organization (organization's uuid).
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
        body: {email: email}
      )
      OrganizationInvitation.new body[:resource], self
    end

    #
    # Revoke Organization Invitation.
    #
    # @param [String] org_uuid the specified organization (organization's uuid).
    # @param [String] inv_uuid the specified invitation (organization invitation's uuid).
    # @return [true]
    # @raise [Calendly::Error] if the org_uuid arg is empty.
    # @raise [Calendly::Error] if the inv_uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.0.7
    def delete_invitation(org_uuid, inv_uuid)
      check_not_empty org_uuid, 'org_uuid'
      check_not_empty inv_uuid, 'inv_uuid'
      request :delete, "organizations/#{org_uuid}/invitations/#{inv_uuid}"
      true
    end

    #
    # Get a webhook subscription for an organization or user with a specified UUID.
    #
    # @param [String] uuid the specified webhook (webhook's uuid).
    # @return [Calendly::WebhookSubscription]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def webhook(uuid_or_uri)
      uri = to_request_uri(uuid_or_uri) { |uuid| "webhook_subscriptions/#{uuid}" }
      body = request :get, uri
      WebhookSubscription.new body[:resource], self
    end

    #
    # Get List of organization scope Webhooks.
    #
    # @param [String] org_uri the specified organization (organization's uri).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Array<Calendly::WebhookSubscription>, Hash>]
    #  - [Array<Calendly::WebhookSubscription>] webhooks
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the org_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def webhooks(org_uri, options: nil)
      check_not_empty org_uri, 'org_uri'

      opts_keys = %i[count page_token sort]
      params = {organization: org_uri, scope: 'organization'}
      params = merge_options options, opts_keys, params
      body = request :get, 'webhook_subscriptions', params: params
      items = body[:collection] || []
      evs = items.map { |item| WebhookSubscription.new item, self }
      [evs, next_page_params(body)]
    end

    #
    # Get List of user scope Webhooks.
    #
    # @param [String] org_uri the specified organization (organization's uri).
    # @param [String] user_uri the specified user (user's uri).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Array<Calendly::WebhookSubscription>, Hash>]
    #  - [Array<Calendly::WebhookSubscription>] webhooks
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the org_uri arg is empty.
    # @raise [Calendly::Error] if the user_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def user_scope_webhooks(org_uri, user_uri, options: nil)
      check_not_empty org_uri, 'org_uri'
      check_not_empty user_uri, 'user_uri'

      opts_keys = %i[count page_token sort]
      params = {organization: org_uri, user: user_uri, scope: 'user'}
      params = merge_options options, opts_keys, params
      body = request :get, 'webhook_subscriptions', params: params
      items = body[:collection] || []
      evs = items.map { |item| WebhookSubscription.new item, self }
      [evs, next_page_params(body)]
    end

    #
    # Create a webhook subscription for an organization or user.
    #
    # @param [String] url Canonical reference (unique identifier) for the resource.
    # @param [Array<String>] events List of user events to subscribe to. options: invitee.created or invitee.canceled or routing_form_submission.created
    # @param [String] org_uri The unique reference to the organization that the webhook will be tied to.
    # @param [String] user_uri The unique reference to the user that the webhook will be tied to. Optional.
    # @param [String] signing_key secret key shared between your application and Calendly. Optional.
    # @return [Calendly::WebhookSubscription]
    # @raise [Calendly::Error] if the url arg is empty.
    # @raise [Calendly::Error] if the events arg is empty.
    # @raise [Calendly::Error] if the org_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def create_webhook(url, events, org_uri, user_uri: nil, signing_key: nil) # rubocop:disable Metrics/ParameterLists
      check_not_empty url, 'url'
      check_not_empty events, 'events'
      check_not_empty org_uri, 'org_uri'

      params = {url: url, events: events, organization: org_uri}
      params[:signing_key] = signing_key if signing_key

      if user_uri
        params[:scope] = 'user'
        params[:user] = user_uri
      else
        params[:scope] = 'organization'
      end
      body = request :post, 'webhook_subscriptions', body: params
      WebhookSubscription.new body[:resource], self
    end

    #
    # Delete a webhook subscription for an organization or user with a specified UUID.
    #
    # @param [String] uuid the specified webhook (webhook's uuid).
    # @return [true]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def delete_webhook(uuid_or_uri)
      uri = to_request_uri(uuid_or_uri) { |uuid| "webhook_subscriptions/#{uuid}" }
      request :delete, uri
      true
    end

    #
    # Get a specified Routing Form.
    #
    # @param [String] uuid the specified routing form (routing form's uuid).
    # @return [Calendly::RoutingForm]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.12.0
    def routing_form(uuid_or_uri)
      uri = to_request_uri(uuid_or_uri) { |uuid| "routing_forms/#{uuid}" }
      body = request :get, uri
      RoutingForm.new body[:resource], self
    end

    #
    # Get a list of Routing Forms for a specified Organization.
    #
    # @param [String] org_uri the specified organization (organization's uri).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and direction. Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Array<Calendly::RoutingForm>, Hash>]
    #  - [Array<Calendly::RoutingForm>] routing forms
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the org_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.12.0
    def routing_forms(org_uri, options: nil)
      check_not_empty org_uri, 'org_uri'

      opts_keys = %i[count page_token sort]
      params = {organization: org_uri}
      params = merge_options options, opts_keys, params
      body = request :get, 'routing_forms', params: params

      items = body[:collection] || []
      forms = items.map { |item| RoutingForm.new item, self }
      [forms, next_page_params(body)]
    end

    #
    # Get a specified Routing Form Submission.
    #
    # @param [String] uuid the specified routing form submission (routing form submission's uuid).
    # @return [Calendly::RoutingFormSubmission]
    # @raise [Calendly::Error] if the uuid arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.12.0
    def routing_form_submission(uuid_or_uri)
      uri = to_request_uri(uuid_or_uri) { |uuid| "routing_form_submissions/#{uuid}" }
      body = request :get, uri
      RoutingFormSubmission.new body[:resource], self
    end

    #
    # Get a list of Routing Form Submissions for a specified Routing Form.
    #
    # @param [String] form_uri the specified organization (routing form's uri).
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and direction. Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Array<Calendly::RoutingFormSubmission>, Hash>]
    #  - [Array<Calendly::RoutingFormSubmission>] routing form submissions
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @raise [Calendly::Error] if the form_uri arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.12.0
    def routing_form_submissions(form_uri, options: nil)
      check_not_empty form_uri, 'form_uri'

      opts_keys = %i[count page_token sort]
      params = {form: form_uri}
      params = merge_options options, opts_keys, params
      body = request :get, 'routing_form_submissions', params: params

      items = body[:collection] || []
      submissions = items.map { |item| RoutingFormSubmission.new item, self }
      [submissions, next_page_params(body)]
    end

    #
    # Create a scheduling link.
    #
    # @param [String] uri A link to the resource that owns this scheduling Link.
    # @param [String] max_event_count The max number of events that can be scheduled using this scheduling link.
    # @param [String] owner_type Resource type.
    # @return [Hash]
    # e.g.
    # {
    #   booking_url: "https://calendly.com/s/FOO-BAR-SLUG",
    #   owner: "https://api.calendly.com/event_types/GBGBDCAADAEDCRZ2",
    #   owner_type: "EventType"
    # }
    # @raise [Calendly::Error] if the uri arg is empty.
    # @raise [Calendly::Error] if the max_event_count arg is empty.
    # @raise [Calendly::Error] if the owner_type arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.5.2
    def create_schedule_link(uri, max_event_count: 1, owner_type: 'EventType')
      check_not_empty uri, 'uri'
      check_not_empty max_event_count, 'max_event_count'
      check_not_empty owner_type, 'owner_type'
      params = {
        max_event_count: max_event_count,
        owner: uri,
        owner_type: owner_type
      }
      body = request :post, 'scheduling_links', body: params
      body[:resource]
    end

  private

    def to_request_uri(uuid_or_uri)
      check_not_empty uuid_or_uri, 'uuid_or_uri'
      return uuid_or_uri if uuid_or_uri.start_with?('http')

      yield uuid_or_uri
    end

    def request(method, path, params: nil, body: nil)
      debug_log "Request #{method.to_s.upcase} #{API_HOST}/#{path} params:#{params}, body:#{body}"
      res = access_token.request method, path, params: params, body: body
      debug_log "Response status:#{res.status}, body:#{res.body.dup&.force_encoding(Encoding::UTF_8)}"
      parse_as_json res
    rescue OAuth2::Error => e
      res = e.response.response
      raise ApiError.new res, e
    end

    def parse_as_json(res)
      return if blank? res.body

      JSON.parse res.body, symbolize_names: true
    rescue JSON::ParserError => e
      raise ApiError.new res, e
    end

    def check_not_empty(value, name)
      raise Error.new("#{name} is required.") if blank? value
    end

    def blank?(value)
      return true if value.nil?
      return true if value.to_s.empty?
      return true if value.is_a?(Array) && value.empty?

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
