# frozen_string_literal: true

require 'calendly/client'
require 'calendly/models/model_utils'

module Calendly
  # Calendly's team model.
  class Team
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/teams/(#{UUID_FORMAT})\z}.freeze

    # @return [String]
    # unique id of the Team object.
    attr_accessor :uuid

    # @return [String]
    # Canonical resource reference.
    attr_accessor :uri
  end
end
