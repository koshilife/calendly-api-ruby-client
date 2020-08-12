# frozen_string_literal: true

module Calendly
  # Calendly's user model.
  # Primary account details of a specific user.
  class User
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/users/(.*)\z}.freeze
    TIME_FIELDS = %i[created_at updated_at].freeze

    # @return [String]
    # unique id of User object.
    attr_accessor :uuid
    # @return [String]
    # Canonical resource reference.
    attr_accessor :uri
    # @return [String]
    # User's human-readable name.
    attr_accessor :name
    # @return [String]
    # Unique readable value used in page URL.
    attr_accessor :slug
    # @return [String]
    # User's email address.
    attr_accessor :email
    # @return [String]
    # URL of user's avatar image.
    attr_accessor :avatar_url
    # @return [String]
    # URL of user's event page.
    attr_accessor :scheduling_url
    # @return [String]
    # Timezone offest to use when presenting time information to user.
    attr_accessor :timezone
    # @return [Time]
    # Moment when user record was first created.
    attr_accessor :created_at
    # @return [Time]
    # Moment when user record was last updated.
    attr_accessor :updated_at
  end
end
