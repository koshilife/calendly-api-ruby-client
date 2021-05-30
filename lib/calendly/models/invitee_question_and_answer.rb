# frozen_string_literal: true

require 'calendly/models/model_utils'

module Calendly
  # Calendly's question and answer model.
  # An individual form question and response.
  class InviteeQuestionAndAnswer
    include ModelUtils

    # @return [String]
    # The question from the event booking confirmation form.
    attr_accessor :question

    # @return [String]
    # The answer supplied by the invitee to this question.
    attr_accessor :answer

    # @return [Integer]
    # The position of this question in the event booking confirmation form.
    attr_accessor :position

  private

    def inspect_attributes
      super + %i[position question]
    end
  end
end
