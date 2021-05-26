# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::Location
  class LocationTest < BaseTest
    def test_it_returns_inspect_string
      assert Location.new.inspect.start_with? '#<Calendly::Location:'
    end
  end
end
