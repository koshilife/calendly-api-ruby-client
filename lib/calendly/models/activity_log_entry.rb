# frozen_string_literal: true

module Calendly
  # Calendly's activity log entry model.
  class ActivityLogEntry
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/activity_log_entries/(#{UUID_FORMAT})\z}.freeze
    TIME_FIELDS = %i[occurred_at].freeze

    def self.association
      {
        organization: Organization
      }
    end

    # @return [String]
    # unique id of the ActivityLogEntry object.
    attr_accessor :uuid

    # @return [String]
    # Canonical reference (unique identifier) for the activity log entry.
    attr_accessor :uri

    # @return [Time]
    # The date and time of the entry.
    attr_accessor :occurred_at

    # @return [Hash]
    # The Calendly actor that took the action creating the activity log entry.
    attr_accessor :actor

    # @return [Hash]
    attr_accessor :details

    # @return [String]
    attr_accessor :fully_qualified_name

    # @return [String]
    # The category associated with the entry.
    attr_accessor :namespace

    # @return [String]
    # The action associated with the entry.
    attr_accessor :action

    # @return [Organization]
    # The organization associated with the entry.
    attr_accessor :organization
  end
end
