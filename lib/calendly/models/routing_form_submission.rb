# frozen_string_literal: true

module Calendly
  # Calendly's routing form submission model.
  class RoutingFormSubmission
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/routing_form_submissions/(#{UUID_FORMAT})\z}.freeze
    TIME_FIELDS = %i[created_at updated_at].freeze

    def self.association
      {
        routing_form: RoutingForm,
        questions_and_answers: RoutingFormSubmissionQuestionAndAnswer,
        tracking: RoutingFormSubmissionTracking,
        result: RoutingFormSubmissionEventTypeResult
      }
    end

    # @return [String]
    # unique id of the RoutingFormSubmission object.
    attr_accessor :uuid

    # @return [String]
    # Canonical reference (unique identifier) for the routing form submission.
    attr_accessor :uri

    # @return [String, nil]
    # The reference to the Invitee resource when routing form submission results in a scheduled meeting.
    attr_accessor :submitter

    # @return [String, nil]
    # Type of the respondent resource that submitted the form and scheduled a meeting.
    attr_accessor :submitter_type

    # @return [Time]
    # Moment when user record was first created.
    attr_accessor :created_at

    # @return [Time]
    # Moment when user record was last updated.
    attr_accessor :updated_at

    # @return [Calendly::RoutingForm]
    # The routing form that's associated with the submission.
    attr_accessor :routing_form

    # @return [Array<Calendly::RoutingFormSubmissionQuestionAndAnswer>]
    # All Routing Form Submission questions with answers.
    attr_accessor :questions_and_answers

    # @return [Calendly::RoutingFormSubmissionTracking]
    # All Routing Form Submission questions with answers.
    attr_accessor :tracking

    # @return [Calendly::RoutingFormSubmissionEventTypeResult]
    # Information about the event type Routing Form Submission result.
    attr_accessor :result

    #
    # Get Routing Form Submission associated with self.
    #
    # @return [Calendly::RoutingFormSubmission]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.12.0
    def fetch
      client.routing_form_submission uuid
    end
  end
end
