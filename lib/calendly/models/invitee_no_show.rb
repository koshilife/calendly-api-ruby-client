# frozen_string_literal: true

module Calendly
  # Calendly's invitee no show model.
  class InviteeNoShow
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/invitee_no_shows/(#{UUID_FORMAT})\z}.freeze
    TIME_FIELDS = %i[created_at].freeze

    def self.association
      {
        invitee: Invitee
      }
    end

    # @return [String]
    # unique id of the InviteeNoShow object.
    attr_accessor :uuid

    # @return [String]
    # Canonical reference (unique identifier) for the no show.
    attr_accessor :uri

    # @return [Time]
    # The moment when the no show was created.
    attr_accessor :created_at

    # @return [Invitee, nil]
    # The associated Invitee.
    attr_accessor :invitee

    #
    # Get Invitee No Show associated with self.
    #
    # @return [Calendly::InviteeNoShow]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.9.0
    def fetch
      client.invitee_no_show uuid
    end

    #
    # Unmarks as a No Show.
    #
    # @return [true]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.9.0
    def delete
      client.delete_invitee_no_show uuid
    end
  end
end
