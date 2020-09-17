# Get a webhook subscription matching the provided UUID for the webhook subscription

# frozen_string_literal: true

module Calendly
  # Calendly's webhook model.
  class WebhookSubscription
    include ModelUtils
    UUID_RE = %r{\A#{Client::API_HOST}/webhook_subscriptions/(\w+)\z}.freeze
    TIME_FIELDS = %i[created_at updated_at retry_started_at].freeze
    ASSOCIATION = {organization: Organization, user: User, creator: User}.freeze

    # @return [String]
    # unique id of the WebhookSubscription object.
    attr_accessor :uuid
    # @return [String]
    # Canonical reference (unique identifier) for the webhook.
    attr_accessor :uri
    # @return [String]
    # The callback URL to use when the event is triggered.
    attr_accessor :callback_url
    # @return [Time]
    # The moment when the webhook subscription was created.
    attr_accessor :created_at
    # @return [Time]
    # The moment when the webhook subscription was last updated.
    attr_accessor :updated_at
    # @return [Time]
    # The date and time the webhook subscription is retried.
    attr_accessor :retry_started_at
    # @return [String]
    # Indicates if the webhook subscription is "active" or "disabled".
    attr_accessor :state
    # @return [Array<String>]
    # A list of events to which the webhook is subscribed.
    attr_accessor :events
    # @return [String]
    # The scope of the webhook subscription.
    attr_accessor :scope
    # @return [Calendly::Organization]
    # The organization that's associated with the webhook subscription.
    attr_accessor :organization
    # @return [Calendly::User]
    # The user that's associated with the webhook subscription.
    attr_accessor :user
    # @return [Calendly::User]
    # The user who created the webhook subscription.
    attr_accessor :creator

    #
    # Get a webhook subscription associated with self.
    #
    # @return [Calendly::WebhookSubscription]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.3
    def fetch
      client.webhook uuid
    end

    #
    # Delete a webhook subscription associated with self.
    #
    # @return [true]
    # @raise [Calendly::Error] if the uuid is empty.
    # @raise [Calendly::ApiError] if the api returns error code.
    # @since 0.1.0
    def delete
      client.delete_webhook uuid
    end
  end
end
