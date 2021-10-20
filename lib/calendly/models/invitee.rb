# frozen_string_literal: true

require 'calendly/client'
require 'calendly/models/model_utils'
require 'calendly/models/event'
require 'calendly/models/invitee_cancellation'
require 'calendly/models/invitee_payment'
require 'calendly/models/invitee_question_and_answer'
require 'calendly/models/invitee_tracking'

module Calendly
  # Calendly's invitee model.
  # An individual who has been invited to meet with a Calendly member.
  class Invitee
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/scheduled_events/\S+/invitees/(\S+)\z}.freeze
    TIME_FIELDS = %i[created_at updated_at].freeze
    ASSOCIATION = {
      event: Event,
      cancellation: InviteeCancellation,
      payment: InviteePayment,
      questions_and_answers: InviteeQuestionAndAnswer,
      tracking: InviteeTracking
    }.freeze

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
    # The first name of the invitee who booked the event when the event type is configured to use separate fields for
    # first name and last name. Null when event type is configured to use a single field for name.
    attr_accessor :first_name

    # @return [String]
    # The last name of the invitee who booked the event when the event type is configured to use separate fields
    # for first name and last name. Null when event type is configured to use a single field for name.
    attr_accessor :last_name

    # @return [String]
    # Whether the invitee has canceled or is still active.
    attr_accessor :status

    # @return [String]
    # Timezone offest to use when presenting time information to invitee.
    attr_accessor :timezone

    # @return [String]
    # Text (SMS) reminder phone number.
    attr_accessor :text_reminder_number

    # @return [Boolean]
    # Indicates if this invitee has rescheduled.
    # If true, a reference to the new Invitee instance is provided in the new_invitee field.
    attr_accessor :rescheduled

    # @return [String, nil]
    # Reference to old Invitee instance that got rescheduled.
    attr_accessor :old_invitee

    # @return [String, nil]
    # Link to new invitee, after reschedule.
    attr_accessor :new_invitee

    # @return [String]
    # Link to cancelling the event for the invitee.
    attr_accessor :cancel_url

    # @return [String]
    # Link to rescheduling the event for the invitee.
    attr_accessor :reschedule_url

    # @return [Time]
    # Moment when user record was first created.
    attr_accessor :created_at

    # @return [Time]
    # Moment when user record was last updated.
    attr_accessor :updated_at

    # @return [InviteeCancellation] Provides data pertaining to the cancellation of the Invitee.
    attr_accessor :cancellation

    # @return [InviteePayment] Invitee payment.
    attr_accessor :payment

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
  end
end
