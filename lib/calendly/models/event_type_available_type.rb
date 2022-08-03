# frozen_string_literal: true

module Calendly
  # An available meeting time slot for the given event type.
  class EventTypeAvailableTime
    include ModelUtils
    TIME_FIELDS = %i[start_time].freeze

    # Indicates that the open time slot is "available".
    # @return [String]
    attr_accessor :status

    # Total remaining invitees for this available time.
    # For Group Event Type, more than one invitee can book in this available time.
    # For all other Event Types, only one invitee can book in this available time.
    # @return [Integer]
    attr_accessor :invitees_remaining

    # The moment the event was scheduled to start in UTC time.
    # @return [Time]
    attr_accessor :start_time

    # The URL of the user’s scheduling site where invitees book this event type.
    # @return [Time]
    attr_accessor :scheduling_url

  private

    def inspect_attributes
      super + %i[start_time invitees_remaining]
    end
  end
end
