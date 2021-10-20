# frozen_string_literal: true

require 'calendly/client'
require 'calendly/models/model_utils'
require 'calendly/models/organization'
require 'calendly/models/user'

module Calendly
  # Calendly's organization invitation model.
  class OrganizationInvitation
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/organizations/#{UUID_FORMAT}/invitations/(#{UUID_FORMAT})\z}.freeze
    TIME_FIELDS = %i[created_at updated_at last_sent_at].freeze
    ASSOCIATION = {user: User, organization: Organization}.freeze

    # @return [String]
    # unique id of the OrganizationInvitation object.
    attr_accessor :uuid

    # @return [String]
    # Canonical resource reference.
    attr_accessor :uri

    # @return [String]
    # Invited person's email.
    attr_accessor :email

    # @return [String]
    # Invitation status.
    attr_accessor :status

    # @return [Time]
    # Moment when user record was first created.
    attr_accessor :created_at

    # @return [Time]
    # Moment when user record was last updated.
    attr_accessor :updated_at

    # @return [Time]
    # Moment when the last invitation was sent.
    attr_accessor :last_sent_at

    # @return [Organization]
    # Reference to Organization associated with this invitation.
    attr_accessor :organization

    # @return [User]
    # If a person accepted the invitation, a reference to their User.
    attr_accessor :user

    #
    # Get Organization Invitation associated with self.
    #
    # @return [Calendly::OrganizationInvitation]
    # @raise [Calendly::Error] if the organization.uuid is empty.
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def fetch
      org_uuid = organization.uuid if organization
      client.invitation org_uuid, uuid
    end

    #
    # Revoke self Invitation.
    #
    # @return [true]
    # @raise [Calendly::Error] if the organization.uuid is empty.
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def delete
      org_uuid = organization.uuid if organization
      client.delete_invitation org_uuid, uuid
    end
  end
end
