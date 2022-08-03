# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::EventTypeAvailableTime
  class EventTypeAvailableTimeTest < BaseTest
    def test_it_returns_inspect_string
      assert EventTypeAvailableTime.new.inspect.start_with? '#<Calendly::EventTypeAvailableTime:'
    end
  end
end
