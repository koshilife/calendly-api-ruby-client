# frozen_string_literal: true

require 'time'

module Calendly
  # Calendly model utility.
  module ModelUtils
    def set_attributes(attributes)
      return unless attributes.is_a? Hash
      return if attributes.empty?

      attributes.each do |key, value|
        next unless respond_to?("#{key}=".to_sym)

        if defined?(self.class::TIME_FIELDS) && self.class::TIME_FIELDS.include?(key)
          value = Time.parse value
        end
        instance_variable_set "@#{key}", value
      end
      after_set_attributes if respond_to?(:after_set_attributes)
      true
    end

    def inspect
      description = "uuid:#{uuid}" if respond_to?(:uuid)
      "\#<#{self.class}:#{object_id} #{description}>"
    end

    module ClassMethods
      def new_from_api(response)
        item = new
        parsed = JSON.parse(response.body, symbolize_names: true)
        item.set_attributes(parsed[:resource])
        item
      rescue StandardError
        nil
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
