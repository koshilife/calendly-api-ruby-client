# frozen_string_literal: true

module Calendly
  # Calendly's event type profile model.
  class EventTypeProfile
    include ModelUtils

    # @return [String]
    # Indicates if the profile belongs to a "user" (individual) or "team"
    attr_accessor :type

    # @return [String]
    # Human-readable name for the profile of the user that's associated with the event type
    attr_accessor :name

    # @return [String]
    # The unique reference to the user associated with the profile
    attr_accessor :owner

    # @return [Calendly::User]
    # The owner user if the profile belongs to a "user" (individual).
    attr_accessor :owner_user

    # @return [Calendly::Team]
    # The owner team if the profile belongs to a "team".
    attr_accessor :owner_team

    # whether type is user or not.
    # @return [Boolean]
    # @since 0.6.0
    def type_user?
      type&.downcase == 'user'
    end

    # whether type is team or not.
    # @return [Boolean]
    # @since 0.6.0
    def type_team?
      type&.downcase == 'team'
    end

  private

    def after_set_attributes(attrs)
      super attrs
      if owner # rubocop:disable Style/GuardClause
        @owner_user = User.new({uri: owner}, @client) if type_user?
        @owner_team = Team.new({uri: owner}, @client) if type_team?
      end
    end
  end
end
