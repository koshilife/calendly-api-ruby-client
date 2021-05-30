# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::InviteeQuestionAndAnswer
  class InviteeQuestionAndAnswerTest < BaseTest
    def test_it_returns_inspect_string
      assert InviteeQuestionAndAnswer.new.inspect.start_with? '#<Calendly::InviteeQuestionAndAnswer:'
    end
  end
end
