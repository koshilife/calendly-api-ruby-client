# frozen_string_literal: true

require 'calendly/client'
require 'calendly/models/model_utils'
require 'calendly/models/event'

module Calendly
  # Calendly's Invitee model.
  # An individual who has been invited to meet with a Calendly member.
  class Invitee
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/scheduled_events/\w+/invitees/(\w+)\z}.freeze
    TIME_FIELDS = %i[created_at updated_at].freeze
    ASSOCIATION = {event: Event}.freeze

    # @return [String]
    # unique id of the Invitee object.
    attr_accessor :uuid
    # @return [String]
    # Canonical resource reference.
    attr_accessor :uri
    # @return [String]
    # The invitee's email address.
    attr_accessor :email
    # @return [String]
    # The invitee's human-readable name.
    attr_accessor :name
    # @return [String]
    # Whether the invitee has canceled or is still active.
    attr_accessor :status
    # @return [String]
    # Timezone offest to use when presenting time information to invitee.
    attr_accessor :timezone
    # @return [String]
    # Text (SMS) reminder phone number.
    attr_accessor :text_reminder_number
    # @return [Time]
    # Moment when user record was first created.
    attr_accessor :created_at
    # @return [Time]
    # Moment when user record was last updated.
    attr_accessor :updated_at

    # @return [Event]
    # Reference to Event associated with this invitee.
    attr_accessor :event

    # @return [Array<Calendly::InviteeQuestionAndAnswer>]
    # A collection of form responses from the invitee.
    attr_accessor :questions_and_answers

    # @return [Calendly::InviteeTracking]
    attr_accessor :tracking

    #
    # Get Event Invitee associated with self.
    #
    # @return [Calendly::Invitee]
    # @raise [Calendly::Error] if the event.uuid is empty.
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def fetch
      ev_uuid = event.uuid if event
      client.event_invitee ev_uuid, uuid
    end

  private

    def after_set_attributes(attrs)
      super attrs
      answers = attrs[:questions_and_answers]
      @questions_and_answers = answers.map { |ans| InviteeQuestionAndAnswer.new ans } if answers&.is_a? Array

      trac_attrs = attrs[:tracking]
      @tracking = InviteeTracking.new trac_attrs if trac_attrs&.is_a? Hash
    end
  end
end
