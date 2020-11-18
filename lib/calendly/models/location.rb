# frozen_string_literal: true

require 'calendly/models/model_utils'

module Calendly
  # Calendly's location model.
  # Polymorphic base type for the various supported meeting locations.
  class Location
    include ModelUtils

    # data patterns is below:
    # - 1. A meeting at a pre-specified physical location
    #  - [String] :kind
    #  - [String] :location A physical location specified by the meeting publisher.
    # - 2. Meeting publisher will call the invitee
    #  - [String] :kind
    # - 3. Invitee will call meeting publisher at the specified phone number.
    #  - [String] :kind
    #  - [String] :phone_number Phone number invitee should use to reach meeting publisher.
    # - 4. Meeting will take place in a Google Meet / Hangout conference.
    #  - [String] :kind
    # - 5. Meeting will take place in a Zoom conference.
    #  - [String] :kind
    # - 6. Meeting will take place in a GotoMeeting conference.
    #  - [String] :kind
    #  - [String] :external_id Zoom-supplied conference id.
    #  - [String] :state Current state of the conference in Zoom.
    #  - [Hash] :data Arbitrary conference metadata supplied by Zoom.
    # - 7. Arbitrary conference metadata supplied by GotoMeeting.
    #  - [String] :kind
    #  - [String] :external_id GotoMeeting-supplied conference id.
    #  - [String] :state Current state of the conference in GotoMeeting.
    #  - [String] :data Arbitrary conference metadata supplied by GotoMeeting.
    # - 8. Meeting location does not fall in a standard category, and is as described by the meeting publisher.
    #  - [String] :kind
    #  - [String] :location Location description provided by meeting publisher.
    # - 9. Meeting location was specified by invitee.
    #  - [String] :kind
    #  - [String] :location Meeting location was specified by invitee.
    #

    # @return [String]
    attr_accessor :kind
    # @return [String]
    attr_accessor :location
    # @return [String]
    attr_accessor :phone_number
    # @return [String]
    attr_accessor :external_id
    # @return [String]
    attr_accessor :state
    # @return [Hash]
    attr_accessor :data
  end
end
