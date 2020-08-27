# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test double for Faraday::Response
  class DoubleFaradayResponse
    attr_accessor :body
    attr_accessor :status
    def initialize(body, status)
      @body = body
      @status = status
    end
  end

  # test for Calendly::Error and Calendly::ApiError
  class ErrorTest < BaseTest
    def setup
      super
    end

    def test_it_returns_inspect_string
      e = Error.new
      assert e.inspect.start_with? '#<Calendly::Error:'

      body = load_test_data 'error_404_not_found.json'
      response = DoubleFaradayResponse.new body, 404
      e = ApiError.new response, nil
      assert e.inspect.start_with? '#<Calendly::ApiError:'
    end
  end
end
