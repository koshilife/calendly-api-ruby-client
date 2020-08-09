# frozen_string_literal: true

module Calendly
  # Calendly apis client error object.
  class ApiError < StandardError
    # @return [Faraday::Response]
    attr_reader :response
    # @return [Integer]
    attr_reader :status
    # @return [String]
    attr_reader :title
    # @return [String]
    attr_reader :message

    def initialize(response)
      @response = response
      @status = response.status
      parsed = response.parsed
      return unless parsed

      @title = parsed['title']
      @message = parsed['message']
      super @message
    end

    def inspect
      "\#<#{self.class}:#{object_id} title:#{title}, status:#{status}>"
    end
  end
end
