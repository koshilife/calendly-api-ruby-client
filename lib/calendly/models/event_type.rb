# frozen_string_literal: true

module Calendly
  # Calendly's event type model.
  # A configuration for a schedulable event
  class EventType
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/event_types/(\w+)\z}.freeze
    TIME_FIELDS = %i[created_at updated_at].freeze

    # @return [String]
    # unique id of the EventType object.
    attr_accessor :uuid
    # @return [String]
    # Canonical resource reference.
    attr_accessor :uri
    # @return [Boolean]
    # Is this event type currently active?
    attr_accessor :active
    # @return [String]
    # The web page styling color for this event type,
    # expressed as a hexadecimal RGB value (e.g. #fa12e4).
    attr_accessor :color
    # @return [String]
    # Longer text description with HTML formatting.
    attr_accessor :description_html
    # @return [String]
    # Longer text description in plain text.
    attr_accessor :description_plain
    # @return [Integer]
    # Length of event type in minutes.
    attr_accessor :duration
    # @return [String]
    # Optional internal note on an event type.
    attr_accessor :internal_note
    # @return [String]
    # Whether the event type is “solo” or with a “group”.
    attr_accessor :kind
    # @return [String]
    # Human-readable name. Note: some Event Types don't have a name.
    attr_accessor :name
    # @return [String]
    # Whether the event type is "round_robin" or "collective".
    # This value is null if the event type does not pool team members' availability.
    attr_accessor :pooling_type
    # @return [String]
    # The full URL of the web page for this event type.
    attr_accessor :scheduling_url
    # @return [String]
    # Unique human-readable slug used in page URL.
    attr_accessor :slug
    # @return [String]
    # Whether the event type is a “StandardEventType” or an "AdhocEventType”.
    attr_accessor :type
    # @return [Time]
    # Moment when event type was eventually created.
    attr_accessor :created_at
    # @return [Time]
    # Moment when event type was last updated.
    attr_accessor :updated_at

    # @return [String]
    # uuid of User or Team object.
    attr_accessor :owner_uuid
    # @return [String]
    # Reference to the profile owner.
    attr_accessor :owner_uri
    # @return [String]
    # Human-readable name.
    attr_accessor :owner_name
    # @return [String]
    # Whether the profile belongs to a “User” or a “Team”.
    attr_accessor :owner_type

    private

    def after_set_attributes(attrs)
      super attrs
      if attrs[:profile]

        @owner_uri = attrs[:profile][:owner]
        @owner_uuid = User.extract_uuid owner_uri
        @owner_name = attrs[:profile][:name]
        @owner_type = attrs[:profile][:type]
      end
    end
  end
end
