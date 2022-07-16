# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::RoutingFormSubmissionQuestionAndAnswer
  class RoutingFormSubmissionQuestionAndAnswerTest < BaseTest
    def test_it_returns_inspect_string
      attrs = {
        question_uuid: 'foobar',
          question: 'Q.Something',
          answer: 'A.Something'
      }
      qa = RoutingFormSubmissionQuestionAndAnswer.new attrs
      assert qa.inspect.start_with? '#<Calendly::RoutingFormSubmissionQuestionAndAnswer:'
    end
  end
end
