# frozen_string_literal: true

module Calendly
  # Calendly's organization invitation model.
  class OrganizationInvitation
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/organizations/\w+/invitations/(\w+)\z}.freeze
    TIME_FIELDS = %i[created_at updated_at last_sent_at].freeze

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

    # @return [String]
    # Reference to Organization uri associated with this invitation.
    attr_accessor :organization_uri
    # @return [String]
    # Reference to Organization uuid associated with this invitation.
    attr_accessor :organization_uuid

    # @return [String]
    # If a person accepted the invitation, a reference to their User uri.
    attr_accessor :user_uri
    # @return [String]
    # If a person accepted the invitation, a reference to their User uuid.
    attr_accessor :user_uuid

    private

    def after_set_attributes(attrs)
      super attrs
      if attrs[:user]
        user_attrs = { uri: attrs[:user] }
        user = User.new user_attrs, @client
        @user_uri = user.uri
        @user_uuid = user.uuid
      end
      if attrs[:organization]
        org_attrs = { uri: attrs[:organization] }
        org = Organization.new org_attrs, @client
        @organization_uri = org.uri
        @organization_uuid = org.uuid
      end
    end
  end
end
