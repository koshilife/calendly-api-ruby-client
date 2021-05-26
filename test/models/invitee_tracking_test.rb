# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::InviteeTracking
  class InviteeTrackingTest < BaseTest
    def test_it_returns_inspect_string
      assert InviteeTracking.new.inspect.start_with? '#<Calendly::InviteeTracking:'
    end
  end
end
