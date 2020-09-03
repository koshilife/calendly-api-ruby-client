# frozen_string_literal: true

module Calendly
  # Calendly apis client error object.
  class ApiError < Calendly::Error
    # @return [Faraday::Response]
    attr_reader :response
    # @return [Integer]
    attr_reader :status
    # @return [String]
    attr_reader :title
    # @return [OAuth2::Error, JSON::ParserError]
    attr_reader :cause_exception

    def initialize(response, cause_exception, message: nil)
      @response = response
      @cause_exception = cause_exception
      @message = message
      set_attributes_from_response
      @message ||= cause_exception.message if cause_exception
      super @message
    end

    def inspect
      "\#<#{self.class}:#{object_id} title:#{title}, status:#{status}>"
    end

  private

    def set_attributes_from_response # rubocop:disable Metrics/CyclomaticComplexity
      return unless response
      return unless response.respond_to? :body

      @status = response.status if response.respond_to? :status
      parsed = JSON.parse response.body, symbolize_names: true
      @title = parsed[:title] || parsed[:error]
      @message ||= parsed[:message] || parsed[:error_description]
    rescue JSON::ParserError
      nil
    end
  end
end
