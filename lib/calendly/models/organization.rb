# frozen_string_literal: true

require 'calendly/client'
require 'calendly/models/model_utils'

module Calendly
  # Calendly's organization model.
  class Organization
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/organizations/(\w+)\z}.freeze

    # @return [String]
    # unique id of the Organization object.
    attr_accessor :uuid

    # @return [String]
    # Canonical resource reference.
    attr_accessor :uri

    #
    # Get List memberships of all users belonging to self.
    #
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :email Filter by email.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @return [Array<Calendly::OrganizationMembership>]
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def memberships(opts = {})
      return @cached_memberships if defined?(@cached_memberships) && @cached_memberships

      request_proc = proc { |options| client.memberships uri, options }
      @cached_memberships = auto_pagination request_proc, opts
    end

    # @since 0.2.0
    def memberships!(opts = {})
      @cached_memberships = nil
      memberships opts
    end

    #
    # Get Organization Invitations.
    #
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :email Filter by email.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @option opts [String] :sort Order results by the specified field and directin.
    # Accepts comma-separated list of {field}:{direction} values.
    # @option opts [String] :status Filter by status.
    # @return [Array<Calendly::OrganizationInvitation>]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def invitations(opts = {})
      return @cached_invitations if defined?(@cached_invitations) && @cached_invitations

      request_proc = proc { |options| client.invitations uuid, options }
      @cached_invitations = auto_pagination request_proc, opts
    end

    # @since 0.2.0
    def invitations!(opts = {})
      @cached_invitations = nil
      invitations opts
    end

    #
    # Invite a person to an Organization.
    #
    # @param [String] email Email of the person being invited.
    # @return [Calendly::OrganizationInvitation]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::Error] if the email is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def create_invitation(email)
      client.create_invitation uuid, email
    end

    #
    # Returns all Event Types associated with self.
    #
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @option opts [String] :sort Order results by the specified field and direction.
    # Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Calendly::EventType>]
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.6.0
    def event_types(opts = {})
      return @cached_event_types if defined?(@cached_event_types) && @cached_event_types

      request_proc = proc { |options| client.event_types uri, options }
      @cached_event_types = auto_pagination request_proc, opts
    end

    # @since 0.6.0
    def event_types!(opts = {})
      @cached_event_types = nil
      event_types opts
    end

    #
    # Returns all Scheduled Events associated with self.
    #
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :invitee_email Return events scheduled with the specified invitee email
    # @option opts [String] :max_start_timeUpper bound (inclusive) for an event's start time to filter by.
    # @option opts [String] :min_start_time Lower bound (inclusive) for an event's start time to filter by.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @option opts [String] :sort Order results by the specified field and directin.
    # Accepts comma-separated list of {field}:{direction} values.
    # @option opts [String] :status Whether the scheduled event is active or canceled
    # @return [Array<Calendly::Event>]
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.5.0
    def scheduled_events(opts = {})
      return @cached_scheduled_events if defined?(@cached_scheduled_events) && @cached_scheduled_events

      request_proc = proc { |options| client.scheduled_events uri, options }
      @cached_scheduled_events = auto_pagination request_proc, opts
    end

    # @since 0.5.0
    def scheduled_events!(opts = {})
      @cached_scheduled_events = nil
      scheduled_events opts
    end

    #
    # Get List of organization scope Webhooks associated with self.
    #
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @option opts [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Calendly::WebhookSubscription>]
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def webhooks(opts = {})
      return @cached_webhooks if defined?(@cached_webhooks) && @cached_webhooks

      request_proc = proc { |options| client.webhooks uri, options }
      @cached_webhooks = auto_pagination request_proc, opts
    end

    # @since 0.2.0
    def webhooks!(opts = {})
      @cached_webhooks = nil
      webhooks opts
    end

    #
    # Create a user scope webhook associated with self.
    #
    # @param [String] url Canonical reference (unique identifier) for the resource.
    # @param [Array<String>] events List of user events to subscribe to. options: invitee.created or invitee.canceled
    # @return [Calendly::WebhookSubscription]
    # @raise [Calendly::Error] if the url arg is empty.
    # @raise [Calendly::Error] if the events arg is empty.
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def create_webhook(url, events, signing_key = nil)
      client.create_webhook url, events, uri, signing_key
    end
  end
end
