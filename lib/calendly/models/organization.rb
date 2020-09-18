# frozen_string_literal: true

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
      return @cached_memberships if @cached_memberships

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
      return @cached_invitations if @cached_invitations

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
      return @cached_webhooks if @cached_webhooks

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
    def create_webhook(url, events)
      client.create_webhook url, events, uri
    end
  end
end
