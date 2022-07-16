# frozen_string_literal: true

module Calendly
  # UTM and Salesforce tracking parameters.
  module TrackingFields
    # @return [String]
    # UTM campaign tracking parameter.
    attr_accessor :utm_campaign

    # @return [String]
    # UTM source tracking parameter.
    attr_accessor :utm_source

    # @return [String]
    # UTM medium tracking parameter.
    attr_accessor :utm_medium

    # @return [String]
    # UTM content tracking parameter.
    attr_accessor :utm_content

    # @return [String]
    # UTM term tracking parameter.
    attr_accessor :utm_term

    # @return [String]
    # Salesforce Record ID.
    attr_accessor :salesforce_uuid

  private

    def inspect_attributes
      super + %i[utm_source utm_medium utm_campaign]
    end
  end
end
