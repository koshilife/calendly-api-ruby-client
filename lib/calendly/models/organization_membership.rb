# frozen_string_literal: true

module Calendly
  # Calendly's organization membership model.
  class OrganizationMembership
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/organization_memberships/(\w+)\z}.freeze
    TIME_FIELDS = %i[created_at updated_at].freeze

    # @return [String]
    # unique id of the OrganizationMembership object.
    attr_accessor :uuid
    # @return [String]
    # Canonical resource reference.
    attr_accessor :uri
    # @return [String]
    # User's role within the organization
    attr_accessor :role
    # @return [Time]
    # Moment when user record was first created.
    attr_accessor :created_at
    # @return [Time]
    # Moment when user record was last updated.
    attr_accessor :updated_at

    # @return [Calendly::User]
    # Primary account details of a specific user.
    attr_accessor :user

    # @return [String]
    # Reference to Organization uri associated with this membership.
    attr_accessor :organization_uri
    # @return [String]
    # Reference to Organization uuid associated with this membership.
    attr_accessor :organization_uuid

    #
    # Get Organization Membership associated with self.
    #
    # @return [Calendly::OrganizationMembership]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def fetch
      client.membership uuid
    end

    #
    # Remove self from associated Organization.
    #
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def delete
      client.delete_membership uuid
    end

    private

    def after_set_attributes(attrs)
      super attrs
      @user = User.new attrs[:user], @client if attrs[:user]&.is_a? Hash
      if attrs[:organization]
        org_attrs = { uri: attrs[:organization] }
        org = Organization.new org_attrs, @client
        @organization_uri = org.uri
        @organization_uuid = org.uuid
      end
    end
  end
end
