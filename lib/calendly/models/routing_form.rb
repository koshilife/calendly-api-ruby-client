# frozen_string_literal: true

module Calendly
  # Calendly's routing form model.
  class RoutingForm
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/routing_forms/(#{UUID_FORMAT})\z}.freeze
    TIME_FIELDS = %i[created_at updated_at].freeze

    def self.association
      {
        organization: Organization,
        questions: RoutingFormQuestion
      }
    end

    # @return [String]
    # unique id of the RoutingForm object.
    attr_accessor :uuid

    # @return [String]
    # Canonical reference (unique identifier) for the routing form.
    attr_accessor :uri

    # @return [String]
    # The routing form name (in human-readable format).
    attr_accessor :name

    # @return [String]
    # Indicates if the form is in "draft" or "published" status.
    attr_accessor :status

    # @return [Time]
    # Moment when user record was first created.
    attr_accessor :created_at

    # @return [Time]
    # Moment when user record was last updated.
    attr_accessor :updated_at

    # @return [Calendly::Organization]
    # The URI of the organization that's associated with the routing form.
    attr_accessor :organization

    # @return [Array<Calendly::RoutingFormQuestion>]
    # An ordered collection of Routing Form non-deleted questions.
    attr_accessor :questions

    #
    # Get Routing Form associated with self.
    #
    # @return [Calendly::RoutingForm]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.12.0
    def fetch
      client.routing_form uuid
    end

    #
    # Returns all Routing Form Submissions associated with self.
    #
    # @param [Hash] options the optional request parameters. Optional.
    # @option options [Integer] :count Number of rows to return.
    # @option options [String] :page_token Pass this to get the next portion of collection.
    # @option options [String] :sort Order results by the specified field and directin. Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Calendly::RoutingFormSubmission>]
    # @raise [Calendly::Error] if the uri is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.12.0
    def submissions(options: nil)
      return @cached_submissions if defined?(@cached_submissions) && @cached_submissions

      request_proc = proc { |opts| client.routing_form_submissions uri, options: opts }
      @cached_submissions = auto_pagination request_proc, options
    end

    # @since 0.12.0
    def submissions!(options: nil)
      @cached_submissions = nil
      submissions options: options
    end
  end
end
