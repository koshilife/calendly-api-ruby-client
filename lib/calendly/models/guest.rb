# frozen_string_literal: true

require 'calendly/models/model_utils'

module Calendly
  # Calendly's guest model.
  # Additional people added to an event by an invitee.
  class Guest
    include ModelUtils
    TIME_FIELDS = %i[created_at updated_at].freeze

    # @return [String]
    attr_accessor :email

    # @return [Time]
    attr_accessor :created_at

    # @return [Time]
    attr_accessor :updated_at
  end
end
