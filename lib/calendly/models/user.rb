# frozen_string_literal: true

module Calendly
  # Calendly's user model.
  class User
    include ModelUtils
    API_URL = "#{Client::API_HOST}/users/"
    TIME_FIELDS = %i[created_at updated_at].freeze

    attr_accessor :uuid
    attr_accessor :uri
    attr_accessor :name
    attr_accessor :slug
    attr_accessor :email
    attr_accessor :avatar_url
    attr_accessor :scheduling_url
    attr_accessor :timezone
    attr_accessor :created_at
    attr_accessor :updated_at

    def after_set_attributes
      @uuid = extract_uuid
    end

    def extract_uuid
      return unless uri
      return if uri.empty?

      re = %r{\A#{API_URL}(.+)\z}
      m = re.match uri
      return if m.nil?

      m[1]
    end
  end
end
