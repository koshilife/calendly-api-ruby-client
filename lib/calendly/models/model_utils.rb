# frozen_string_literal: true

require 'time'

module Calendly
  # Calendly model utility.
  module ModelUtils
    def initialize(attrs = nil)
      set_attributes attrs
    end

    def inspect
      description = "uuid:#{uuid}" if respond_to? :uuid
      "\#<#{self.class}:#{object_id} #{description}>"
    end

    module ClassMethods
      DEFAULT_UUID_RE_INDEX = 1
      def extract_uuid(str)
        return unless defined? self::UUID_RE
        return unless str
        return if str.empty?

        m = self::UUID_RE.match str
        return if m.nil?

        index = self::UUID_RE_INDEX if defined? self::UUID_RE_INDEX
        index ||= DEFAULT_UUID_RE_INDEX
        m[index]
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    private

    def set_attributes(attrs)
      return if attrs.nil?
      return unless attrs.is_a? Hash
      return if attrs.empty?

      attrs.each do |key, value|
        next unless respond_to? "#{key}=".to_sym

        if defined?(self.class::TIME_FIELDS) && self.class::TIME_FIELDS.include?(key)
          value = Time.parse value
        end
        instance_variable_set "@#{key}", value
      end
      after_set_attributes(attrs)
    end

    def after_set_attributes(attrs)
      @uuid = self.class.extract_uuid(attrs[:uri]) if respond_to? :uuid=
      true
    end
  end
end
