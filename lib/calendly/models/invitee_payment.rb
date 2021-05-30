# frozen_string_literal: true

require 'calendly/models/model_utils'

module Calendly
  # Calendly's invitee payment model.
  class InviteePayment
    include ModelUtils

    # @return [String] Unique identifier for the payment.
    attr_accessor :external_id

    # @return [String] Payment provider.
    attr_accessor :provider

    # @return[Float] The amount of the payment.
    attr_accessor :amount

    # @return [String] The currency format that the payment is in.
    attr_accessor :currency

    # @return [String] Terms of the payment.
    attr_accessor :terms

    # @return [Boolean] Indicates whether the payment was successfully processed.
    attr_accessor :successful
  end
end
