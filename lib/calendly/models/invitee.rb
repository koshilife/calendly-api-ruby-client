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

    # @return [String]
    # Reason that the cancellation occurred.
    attr_accessor :cancellation_canceled_by

    # @return [String]
    # Name of the person whom canceled.
    attr_accessor :cancellation_reason

    # @return [String]
    # Unique identifier for the payment.
    attr_accessor :payment_external_id

    # @return [String]
    # Payment provider.
    attr_accessor :payment_provider

    # @return [Float]
    # The amount of the payment.
    attr_accessor :payment_amount

    # @return [String]
    # The currency format that the payment is in.
    attr_accessor :payment_currency

    # @return [String]
    # Terms of the payment.
    attr_accessor :payment_terms

    # @return [Boolean]
    # Indicates whether the payment was successfully processed.
    attr_accessor :payment_successful

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

      cancel_info = attrs[:cancellation]
      if cancel_info.is_a? Hash
        @cancellation_canceled_by = cancel_info[:canceled_by]
        @cancellation_reason = cancel_info[:reason]
      end

      payment_info = attrs[:payment]
      if payment_info.is_a? Hash
        @payment_external_id = payment_info[:external_id]
        @payment_provider = payment_info[:provider]
        @payment_amount = payment_info[:amount]
        @payment_currency = payment_info[:currency]
        @payment_terms = payment_info[:terms]
        @payment_successful = payment_info[:successful]
      end

      answers = attrs[:questions_and_answers]
      @questions_and_answers = answers.map { |params| InviteeQuestionAndAnswer.new params } if answers.is_a? Array

      tracking_info = attrs[:tracking]
      @tracking = InviteeTracking.new tracking_info if tracking_info.is_a? Hash
    end
  end
end
