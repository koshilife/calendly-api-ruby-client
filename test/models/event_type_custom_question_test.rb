# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::EventTypeCustomQuestion
  class EventTypeCustomQuestionTest < BaseTest
    def test_it_returns_inspect_string
      assert EventTypeCustomQuestion.new.inspect.start_with? '#<Calendly::EventTypeCustomQuestion:'
    end
  end
end
