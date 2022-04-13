# frozen_string_literal: true

require 'calendly/client'
require 'calendly/models/model_utils'
Dir[
  File.join(
    File.dirname(__FILE__),
    'calendly',
    '**',
    '*'
  )
].sort.each do |f|
  next if File.directory? f

  require f
end

# module for Calendly apis client
module Calendly
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
