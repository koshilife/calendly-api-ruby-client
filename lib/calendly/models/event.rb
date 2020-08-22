# frozen_string_literal: true

module Calendly
  # Calendly's event model.
  # A meeting that has been scheduled
  class Event
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/scheduled_events/(\w+)\z}.freeze
    TIME_FIELDS = %i[start_time end_time created_at updated_at].freeze

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
    # @return [String]
    # Reference to Event Type uri associated with this event.
    attr_accessor :event_type_uri
    # @return [String]
    # Reference to Event Type uuid associated with this event.
    attr_accessor :event_type_uuid
    # @return [Time]
    # Moment when user record was first created.
    attr_accessor :created_at
    # @return [Time]
    # Moment when user record was last updated.
    attr_accessor :updated_at

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

    private

    def after_set_attributes(attrs)
      super attrs
      if attrs[:event_type]
        ev_type_params = { uri: attrs[:event_type] }
        event_type = EventType.new ev_type_params
        @event_type_uri = event_type.uri
        @event_type_uuid = event_type.uuid
      end

      loc_params = attrs[:location]
      @location = Location.new loc_params if loc_params&.is_a? Hash

      inv_cnt_params = attrs[:invitees_counter]
      if inv_cnt_params&.is_a? Hash
        @invitees_counter_total = inv_cnt_params[:total]
        @invitees_counter_active = inv_cnt_params[:active]
        @invitees_counter_limit = inv_cnt_params[:limit]
      end

      true
    end
  end
end
