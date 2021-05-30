# frozen_string_literal: true

require 'calendly/client'
require 'calendly/models/model_utils'
require 'calendly/models/event_type_profile'
require 'calendly/models/event_type_custom_question'

module Calendly
  # Calendly's event type model.
  # A configuration for a schedulable event.
  class EventType
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/event_types/(\w+)\z}.freeze
    TIME_FIELDS = %i[created_at updated_at].freeze
    ASSOCIATION = {profile: EventTypeProfile, custom_questions: EventTypeCustomQuestion}.freeze

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

    # @return [Boolean]
    # Indicates if the event type is hidden on the owner's main scheduling page.
    attr_accessor :secret

    # @return [Time]
    # Moment when event type was eventually created.
    attr_accessor :created_at

    # @return [Time]
    # Moment when event type was last updated.
    attr_accessor :updated_at

    # @return [EventTypeProfile]
    # The profile of the User that's associated with the Event Type.
    attr_accessor :profile

    # @return [Array<EventTypeCustomQuestion>]
    # A collection of custom questions.
    attr_accessor :custom_questions

    # The owner user if the profile belongs to a "user" (individual).
    # @return [User]
    # @since 0.6.0
    def owner_user
      profile&.owner_user
    end

    # The owner team if the profile belongs to a "team".
    # @return [Team]
    # @since 0.6.0
    def owner_team
      profile&.owner_team
    end

    #
    # Get EventType associated with self.
    #
    # @return [Calendly::EventType]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.5.1
    def fetch
      client.event_type uuid
    end

    #
    # Create an associated scheduling link.
    #
    # @param [String] max_event_count The max number of events that can be scheduled using this scheduling link.
    # @return [Hash]
    # e.g.
    # {
    #   booking_url: "https://calendly.com/s/FOO-BAR-SLUG",
    #   owner: "https://api.calendly.com/event_types/GBGBDCAADAEDCRZ2",
    #   owner_type: "EventType"
    # }
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::Error] if the max_event_count arg is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.5.2
    def create_schedule_link(max_event_count = 1)
      client.create_schedule_link uri, max_event_count, resource_type: 'EventType'
    end

  private

    def inspect_attributes
      super + %i[active kind scheduling_url]
    end
  end
end
