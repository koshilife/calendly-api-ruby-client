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
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :email Filter by email.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @return [Array<Calendly::OrganizationMembership>]
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def memberships(options: nil)
      return @cached_memberships if defined?(@cached_memberships) && @cached_memberships

      request_proc = proc { |opts| client.memberships uri, options: opts }
      @cached_memberships = auto_pagination request_proc, options
    end

    # @since 0.2.0
    def memberships!(options: nil)
      @cached_memberships = nil
      memberships options: options
    end

    #
    # Get Organization Invitations.
    #
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :email Filter by email.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and directin.
    # Accepts comma-separated list of {field}:{direction} values.
    # @option options [String] :status Filter by status.
    # @return [Array<Calendly::OrganizationInvitation>]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def invitations(options: nil)
      return @cached_invitations if defined?(@cached_invitations) && @cached_invitations

      request_proc = proc { |opts| client.invitations uuid, options: opts }
      @cached_invitations = auto_pagination request_proc, options
    end

    # @since 0.2.0
    def invitations!(options: nil)
      @cached_invitations = nil
      invitations options: options
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
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and direction.
    # Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Calendly::EventType>]
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.6.0
    def event_types(options: nil)
      return @cached_event_types if defined?(@cached_event_types) && @cached_event_types

      request_proc = proc { |opts| client.event_types uri, options: opts }
      @cached_event_types = auto_pagination request_proc, options
    end

    # @since 0.6.0
    def event_types!(options: nil)
      @cached_event_types = nil
      event_types options: options
    end

    #
    # Returns all Scheduled Events associated with self.
    #
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :invitee_email Return events scheduled with the specified invitee email
    # @option options [String] :max_start_timeUpper bound (inclusive) for an event's start time to filter by.
    # @option options [String] :min_start_time Lower bound (inclusive) for an event's start time to filter by.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and directin.
    # Accepts comma-separated list of {field}:{direction} values.
    # @option options [String] :status Whether the scheduled event is active or canceled
    # @return [Array<Calendly::Event>]
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.5.0
    def scheduled_events(options: nil)
      return @cached_scheduled_events if defined?(@cached_scheduled_events) && @cached_scheduled_events

      request_proc = proc { |opts| client.scheduled_events uri, options: opts }
      @cached_scheduled_events = auto_pagination request_proc, options
    end

    # @since 0.5.0
    def scheduled_events!(options: nil)
      @cached_scheduled_events = nil
      scheduled_events options: options
    end

    #
    # Get List of organization scope Webhooks associated with self.
    #
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Calendly::WebhookSubscription>]
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def webhooks(options: nil)
      return @cached_webhooks if defined?(@cached_webhooks) && @cached_webhooks

      request_proc = proc { |opts| client.webhooks uri, options: opts }
      @cached_webhooks = auto_pagination request_proc, options
    end

    # @since 0.2.0
    def webhooks!(options: nil)
      @cached_webhooks = nil
      webhooks options: options
    end

    #
    # Create a user scope webhook associated with self.
    #
    # @param [String] url Canonical reference (unique identifier) for the resource.
    # @param [Array<String>] events List of user events to subscribe to. options: invitee.created or invitee.canceled
    # @param [String] signing_key secret key shared between your application and Calendly. Optional.
    # @return [Calendly::WebhookSubscription]
    # @raise [Calendly::Error] if the url arg is empty.
    # @raise [Calendly::Error] if the events arg is empty.
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def create_webhook(url, events, signing_key: nil)
      client.create_webhook url, events, uri, signing_key: signing_key
    end
  end
end
