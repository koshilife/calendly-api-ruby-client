# frozen_string_literal: true

module Calendly
  # Calendly's routing form question model.
  class RoutingFormQuestion
    include ModelUtils
    TIME_FIELDS = %i[created_at updated_at].freeze

    # @return [String]
    # Unique identifier for the routing form question.
    attr_accessor :uuid

    # @return [String]
    # Question name (in human-readable format).
    attr_accessor :name

    # @return [String]
    # Question type: name, text input, email, phone, textarea input, dropdown list or radio button list.
    attr_accessor :type

    # @return [Boolean]
    # true if an answer to the question is required for respondents to submit the routing form; false if not required.
    attr_accessor :required

    # @return [Array<String>]
    # The respondent’s option(s) for "select" or "radios" types of questions.
    attr_accessor :answer_choices
  end
end
