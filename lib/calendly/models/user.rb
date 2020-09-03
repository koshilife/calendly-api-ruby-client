# frozen_string_literal: true

module Calendly
  # Calendly's user model.
  # Primary account details of a specific user.
  class User
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/users/(\w+)\z}.freeze
    TIME_FIELDS = %i[created_at updated_at].freeze

    # @return [String]
    # unique id of the User object.
    attr_accessor :uuid
    # @return [String]
    # Canonical resource reference.
    attr_accessor :uri
    # @return [String]
    # User's human-readable name.
    attr_accessor :name
    # @return [String]
    # Unique readable value used in page URL.
    attr_accessor :slug
    # @return [String]
    # User's email address.
    attr_accessor :email
    # @return [String]
    # URL of user's avatar image.
    attr_accessor :avatar_url
    # @return [String]
    # URL of user's event page.
    attr_accessor :scheduling_url
    # @return [String]
    # Timezone offest to use when presenting time information to user.
    attr_accessor :timezone
    # @return [Time]
    # Moment when user record was first created.
    attr_accessor :created_at
    # @return [Time]
    # Moment when user record was last updated.
    attr_accessor :updated_at

    #
    # Get basic information associated with self.
    #
    # @return [Calendly::User]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def fetch
      client.user uuid
    end

    #
    # Get an organization membership information associated with self.
    #
    # @return [Calendly::OrganizationMembership]
    # @raise [Calendly::Error] if the uri is empty.
    # @since 0.1.0
    def organization_membership
      mems, = client.memberships_by_user uri
      mems.first
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
    # @since 0.1.0
    def event_types(opts = {})
      request_proc = proc { |options| client.event_types uri, options }
      auto_pagination request_proc, opts
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
    # @since 0.1.0
    def scheduled_events(opts = {})
      request_proc = proc { |options| client.scheduled_events uri, options }
      auto_pagination request_proc, opts
    end
  end
end
