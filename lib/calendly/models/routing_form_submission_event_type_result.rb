# frozen_string_literal: true

module Calendly
  # Event type Routing Form Submission result.
  class RoutingFormSubmissionEventTypeResult
    include ModelUtils

    # @return [String]
    # If the type is event_type, indicates that the routing form submission resulted in a redirect to an event type booking page.
    # If the type is external_url, indicates that the routing form submission resulted in a redirect to an external URL.
    # If the type is custom_message, indicates if the routing form submission resulted in a custom "thank you" message.
    attr_accessor :type

    # @return [String, Hash]
    # If the type is event_type, a reference to the event type resource.
    # If the type is external_url, the external URL the respondent were redirected to.
    # If the type is custom_message, contains an Hash with custom message headline and body.
    attr_accessor :value
  end
end
