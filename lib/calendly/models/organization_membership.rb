# frozen_string_literal: true

require 'calendly/client'
require 'calendly/models/model_utils'
require 'calendly/models/organization'
require 'calendly/models/user'

module Calendly
  # Calendly's organization membership model.
  class OrganizationMembership
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/organization_memberships/(\w+)\z}.freeze
    TIME_FIELDS = %i[created_at updated_at].freeze
    ASSOCIATION = {user: User, organization: Organization}.freeze

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

    # @return [Organization]
    # Reference to Organization associated with this membership.
    attr_accessor :organization

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

    #
    # Get List of user scope Webhooks associated with self.
    #
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Calendly::WebhookSubscription>]
    # @raise [Calendly::Error] if the organization.uri is empty.
    # @raise [Calendly::Error] if the user.uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def user_scope_webhooks(options: nil)
      user.webhooks options: options
    end

    # @since 0.2.0
    def user_scope_webhooks!(options: nil)
      user.webhooks! options: options
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
    # @raise [Calendly::Error] if the organization.uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def create_user_scope_webhook(url, events, signing_key: nil)
      user.create_webhook url, events, signing_key: signing_key
    end

  private

    def after_set_attributes(attrs)
      super attrs
      if user.is_a?(User) && user.current_organization.nil? && organization.is_a?(Organization) # rubocop:disable Style/GuardClause
        user.current_organization = organization
      end
    end

    def inspect_attributes
      super + %i[role]
    end
  end
end
