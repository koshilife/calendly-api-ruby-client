# frozen_string_literal: true

module Calendly
  # Calendly's invitee model.
  # An individual who has been invited to meet with a Calendly member.
  class Invitee
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/scheduled_events/(#{UUID_FORMAT})/invitees/(#{UUID_FORMAT})\z}.freeze
    UUID_RE_INDEX = 2
    TIME_FIELDS = %i[created_at updated_at].freeze

    def self.association
      {
        event: Event,
        cancellation: InviteeCancellation,
        payment: InviteePayment,
        no_show: InviteeNoShow,
        questions_and_answers: InviteeQuestionAndAnswer,
        tracking: InviteeTracking,
        routing_form_submission: RoutingFormSubmission
      }
    end

    def self.extract_event_uuid(str)
      m = extract_uuid_match str
      return unless m

      m[1]
    end

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

    # @return [Calendly::InviteeCancellation] Provides data pertaining to the cancellation of the Invitee.
    attr_accessor :cancellation

    # @return [Calendly::InviteePayment] Invitee payment.
    attr_accessor :payment

    # @return [Calendly::InviteeNoShow, nil]
    # Provides data pertaining to the associated no show for the Invitee.
    attr_accessor :no_show

    # @return [Event]
    # Reference to Event associated with this invitee.
    attr_accessor :event

    # @return [Array<Calendly::InviteeQuestionAndAnswer>]
    # A collection of form responses from the invitee.
    attr_accessor :questions_and_answers

    # @return [Calendly::InviteeTracking]
    attr_accessor :tracking

    # @return [Calendly::RoutingFormSubmission, nil]
    attr_accessor :routing_form_submission

    #
    # Get Event Invitee associated with self.
    #
    # @return [Calendly::Invitee]
    # @raise [Calendly::Error] if the event.uuid is empty.
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def fetch
      client.event_invitee event&.uuid, uuid
    end

    #
    # Marks as a No Show.
    # If already marked as a No Show, do nothing.
    #
    # @return [Calendly::InviteeNoShow]
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.9.0
    def mark_no_show
      return no_show if no_show

      @no_show = client.create_invitee_no_show uri
    end

    #
    # Unmarks as a No Show.
    # If already unmarked as a No Show, do nothing.
    #
    # @return [true, nil]
    # @raise [Calendly::Error] if the no_show.uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.9.0
    def unmark_no_show
      return unless no_show

      no_show.delete
      @no_show = nil
      true
    end

  private

    def after_set_attributes(attrs)
      super attrs
      if event.nil? && attrs[:uri]
        event_uuid = Invitee.extract_event_uuid attrs[:uri]
        @event = Event.new({uuid: event_uuid}, @client) if event_uuid
      end
    end
  end
end
