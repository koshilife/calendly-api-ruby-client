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
      request_proc = proc { |options| client.memberships uri, options }
      auto_pagination request_proc, opts
    end

    #
    # Get Organization Invitations.
    #
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :email Filter by email.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @option opts [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # @option opts [String] :status Filter by status.
    # @return [Array<Calendly::OrganizationInvitation>]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def invitations(opts = {})
      request_proc = proc { |options| client.invitations uuid, options }
      auto_pagination request_proc, opts
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
  end
end
