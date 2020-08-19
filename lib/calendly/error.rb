# frozen_string_literal: true

module Calendly
  # calendly module's base error object
  class Error < StandardError
    def initialize(message = nil)
      @logger = Calendly.configuration.logger
      log "#{self.class} occured. message:#{message}"
      super message
    end

    private

    def log(msg, level = :warn)
      return if @logger.nil?

      @logger.send level, msg
    end
  end
end
