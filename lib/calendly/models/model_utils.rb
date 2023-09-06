# frozen_string_literal: true

require 'time'

module Calendly
  # Calendly model utility.
  module ModelUtils
    # UUID's format is ASCII.
    # refs to official release note of October 2021.
    UUID_FORMAT = '[[:ascii:]]+'

    # @param [Hash] attrs the attributes of the model.
    # @param [Calendly::Client] the api client.
    def initialize(attrs = nil, client = nil)
      @client = client
      @data = attrs || {}
      set_attributes attrs
    end

    #
    # Returns api client.
    #
    # @return [Calendly::Client]
    # @raise [Calendly::Error] if the client is nil.
    # @since 0.1.0
    def client
      raise Error.new('@client is not ready.') if !@client || !@client.is_a?(Client)

      @client
    end

    #
    # Alias of uuid.
    #
    # @return [String]
    # @raise [Calendly::Error] if uuid is not defined.
    # @since 0.1.0
    def id
      raise Error.new('uuid is not defined.') unless defined? uuid

      uuid
    end

    #
    # Self object description human readable in CLI.
    #
    # @return [String]
    # @since 0.0.1
    def inspect
      att_info = []

      # Print out all the attributes, showing the key ones (defined in inspect_attributes) first
      (inspect_attributes + @data.keys).uniq.each do |att|
        next unless respond_to? att

        att_info << "#{att}=#{send(att).inspect}"
      end

      "\#<#{self.class}:#{object_id} #{att_info.join(', ')}>"
    end

    def to_h
      @data
    end

    module ClassMethods
      def extract_uuid_match(str)
        return unless defined? self::UUID_RE
        return unless str
        return if str.empty?

        self::UUID_RE.match str
      end

      def extract_uuid(str)
        m = extract_uuid_match str
        return unless m

        defined?(self::UUID_RE_INDEX) ? m[self::UUID_RE_INDEX] : m[1]
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

  private

    def set_attributes(attrs) # rubocop:disable Naming/AccessorMethodName, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return if attrs.nil?
      return unless attrs.is_a? Hash
      return if attrs.empty?

      attrs.each do |key, value|
        next unless respond_to? "#{key}=".to_sym

        if value && defined?(self.class.association) && self.class.association.key?(key)
          klass = self.class.association[key]
          if value.is_a? String # rubocop:disable Style/CaseLikeIf
            value = klass.new({uri: value}, @client)
          elsif value.is_a? Hash
            value = klass.new(value, @client)
          elsif value.is_a? Array
            value = value.map { |v| klass.new(v, @client) }
          end
        elsif value && defined?(self.class::TIME_FIELDS) && self.class::TIME_FIELDS.include?(key)
          value = Time.parse value
        end
        instance_variable_set "@#{key}", value
      end
      after_set_attributes(attrs)
    end

    def after_set_attributes(attrs)
      return unless respond_to? :uuid=
      return unless attrs[:uri]

      @uuid = self.class.extract_uuid(attrs[:uri])
    end

    #
    # Get all collection from single page or plurality of pages.
    #
    # @param [Proc] request_proc the procedure of request portion of collection.
    # @param [Hash] opts the optional request parameters for the procedure.
    # @return [Array<Calendly::Model>]
    # @since 0.1.0
    def auto_pagination(request_proc, opts)
      items = []
      loop do
        new_items, next_opts = request_proc.call opts
        items = [*items, *new_items]
        break unless next_opts

        opts = next_opts
      end
      items
    end

    #
    # Basic attributes used by inspect method.
    #
    # @return [Array<Symbol>]
    # @since 0.6.0
    def inspect_attributes
      %i[uuid name type slug status email]
    end
  end
end
