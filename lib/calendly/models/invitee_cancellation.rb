# frozen_string_literal: true

require 'calendly/models/model_utils'

module Calendly
  # Calendly's invitee cancellation model.
  # Provides data pertaining to the cancellation of the Invitee.
  class InviteeCancellation
    include ModelUtils

    # @return [String] Name of the person whom canceled.
    attr_accessor :canceled_by

    # @return [String] Reason that the cancellation occurred.
    attr_accessor :reason

    # @return [String] Allowed values: host or invitee.
    attr_accessor :canceler_type
  end
end
