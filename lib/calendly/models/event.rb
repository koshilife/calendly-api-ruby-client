# frozen_string_literal: true

module Calendly
  # Calendly's event model.
  # A meeting that has been scheduled
  class Event
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/scheduled_events/(\w+)\z}.freeze
    TIME_FIELDS = %i[start_time end_time created_at updated_at].freeze
    ASSOCIATION = {event_type: EventType}.freeze

    # @return [String]
    # unique id of the Event object.
    attr_accessor :uuid
    # @return [String]
    # Canonical resource reference.
    attr_accessor :uri
    # @return [String]
    # Name of the event.
    attr_accessor :name
    # @return [String]
    # Whether the event is active or canceled.
    attr_accessor :status
    # @return [Time]
    # Moment when event is (or was) scheduled to begin.
    attr_accessor :start_time
    # @return [Time]
    # Moment when event is (or was) scheduled to end.
    attr_accessor :end_time
    # @return [Time]
    # Moment when user record was first created.
    attr_accessor :created_at
    # @return [Time]
    # Moment when user record was last updated.
    attr_accessor :updated_at

    # @return [EventType]
    # Reference to Event Type associated with this event.
    attr_accessor :event_type

    # @return [Calendly::Location]
    # location in this event.
    attr_accessor :location

    # @return [Integer]
    # number of total invitees in this event.
    attr_accessor :invitees_counter_total
    # @return [Integer]
    # number of active invitees in this event.
    attr_accessor :invitees_counter_active
    # @return [Integer]
    # max invitees in this event.
    attr_accessor :invitees_counter_limit

    #
    # Get Scheduled Event associated with self.
    #
    # @return [Calendly::Event]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def fetch
      client.scheduled_event uuid
    end

    #
    # Returns all Event Invitees associated with self.
    #
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :email Filter by email.
    # @option opts [String] :page_token
    # Pass this to get the next portion of collection.
    # @option opts [String] :sort Order results by the specified field and directin.
    # Accepts comma-separated list of {field}:{direction} values.
    # @option opts [String] :status Whether the scheduled event is active or canceled.
    # @return [Array<Calendly::Invitee>]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def invitees(opts = {})
      request_proc = proc { |options| client.event_invitees uuid, options }
      auto_pagination request_proc, opts
    end

  private

    def after_set_attributes(attrs)
      super attrs
      loc_params = attrs[:location]
      @location = Location.new loc_params if loc_params&.is_a? Hash

      inv_cnt_attrs = attrs[:invitees_counter]
      return unless inv_cnt_attrs
      return unless inv_cnt_attrs.is_a? Hash

      @invitees_counter_total = inv_cnt_attrs[:total]
      @invitees_counter_active = inv_cnt_attrs[:active]
      @invitees_counter_limit = inv_cnt_attrs[:limit]
    end
  end
end
