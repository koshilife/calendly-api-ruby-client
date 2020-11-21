# frozen_string_literal: true

require 'calendly/models/model_utils'

module Calendly
  # Calendly's location model.
  # The polymorphic base type for an event location that Calendly supports
  class Location
    include ModelUtils

    #
    # data patterns is below:
    #
    # 1. In-Person Meeting: Information about the physical (in-person) event location.
    # @param [String] type Indicates that the event host (publisher) will call the invitee.
    # @param [String] location The physical location specified by the event host (publisher).
    #
    # 2. Outbound Call: Meeting publisher will call the Invitee
    # @param [String] type Indicates that the event host (publisher) will call the invitee.
    # @param [String] location The phone number the event host (publisher) will use to call the invitee.
    #
    # 3. Inbound Call: Invitee will call meeting publisher at the specified phone number.
    # @param [String] type Indicates that the invitee will call the event host.
    # @param [String] location The phone number the invitee will use to call the event host (publisher).
    #
    # 4. Google Conference: Details about an Event that will take place using a Google Meet / Hangout conference.
    # @param [String] type The event location is a Google Meet or Hangouts conference.
    # @param [String] status Indicates the current status of the Google conference.
    # @param [String] join_url Google conference meeting url.
    #
    # 5. Zoom Conference: Meeting will take place in a Zoom conference.
    # @param [String] type The event location is a Zoom conference
    # @param [String] status Indicates the current status of the Zoom conference.
    # @param [String] join_url Zoom meeting url.
    # @param [Hash] data The conference metadata supplied by Zoom.
    #
    # 6. GoToMeeting Conference: Details about an Event that will take place using a GotoMeeting conference
    # @param [String] type The event location is a GoToMeeting conference.
    # @param [String] status Indicates the current status of the GoToMeeting conference.
    # @param [String] join_url GoToMeeting conference meeting url.
    # @param [Hash] data The conference metadata supplied by GoToMeeting.
    #
    # 7. Microsoft Teams Conference:
    # @param [String] type The event location is a Zoom conference.
    # @param [String] status Indicates the current status of the Microsoft Teams conference.
    # @param [String] join_url Microsoft Teams meeting url.
    # @param [Hash] data The conference metadata supplied by Microsoft Teams.
    #
    # 8. Custom Location:
    # Use this to describe an existing Calendly-supported event location.
    # @param [String] type The event location doesn't fall into a standard category defined by the event host (publisher).
    # @param [String] location The event location description provided by the invitee.
    #
    # 9. Invitee Specified Location:
    # Information about an event location that’s specified by the invitee.
    # @param [String] type The event location selected by the invitee.
    # @param [String] location The event location description provided by the invitee.
    #

    # @return [String]
    attr_accessor :type
    # @return [String]
    attr_accessor :location
    # @return [String]
    attr_accessor :status
    # @return [String]
    attr_accessor :join_url
    # @return [Hash]
    attr_accessor :data
  end
end
