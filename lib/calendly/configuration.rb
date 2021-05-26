# frozen_string_literal: true

require 'logger'

module Calendly
  # Calendly apis client configuration.
  class Configuration
    # @return [String]
    attr_accessor :client_id

    # @return [String]
    attr_accessor :client_secret

    # @return [String]
    attr_accessor :token

    # @return [String]
    attr_accessor :refresh_token

    # @return [Integer]
    attr_accessor :token_expires_at

    # @return [Logger]
    attr_accessor :logger

    def initialize
      @logger = Logger.new $stdout
      @logger.level = :warn
    end
  end
end
