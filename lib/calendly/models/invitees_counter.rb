# frozen_string_literal: true

require 'calendly/models/model_utils'

module Calendly
  # Calendly's invitees counter model.
  class InviteesCounter
    include ModelUtils

    # @return [Integer] number of total invitees in this event.
    attr_accessor :total

    # @return [Integer] number of active invitees in this event.
    attr_accessor :active

    # @return [Integer] max invitees in this event.
    attr_accessor :limit
  end
end
