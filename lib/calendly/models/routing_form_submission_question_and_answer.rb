# frozen_string_literal: true

module Calendly
  # Routing Form Submission question with answer.
  class RoutingFormSubmissionQuestionAndAnswer
    include ModelUtils

    # @return [String]
    # Unique identifier for the routing form question.
    attr_accessor :question_uuid
    alias uuid question_uuid

    # @return [String]
    # Question name (in human-readable format).
    attr_accessor :question

    # @return [String]
    # Answer provided by the respondent when the form was submitted.
    attr_accessor :answer

  private

    def inspect_attributes
      super + %i[question]
    end
  end
end
