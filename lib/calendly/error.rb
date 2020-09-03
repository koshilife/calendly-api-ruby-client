# frozen_string_literal: true

module Calendly
  # calendly module's base error object
  class Error < StandardError
    include Loggable

    def initialize(message = nil)
      @logger = Calendly.configuration.logger
      msg = "#{self.class} occured."
      msg += " status:#{status}" if respond_to?(:status)
      msg += " message:#{message}"
      warn_log msg
      super message
    end
  end
end
