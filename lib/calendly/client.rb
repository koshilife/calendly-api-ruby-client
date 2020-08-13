# frozen_string_literal: true

require 'oauth2'
require 'faraday_middleware'

module Calendly
  # Calendly apis client.
  class Client
    API_HOST = 'https://api.calendly.com'
    AUTH_API_HOST = 'https://auth.calendly.com'

    # @param [String] token a Calendly's access token.
    def initialize(token = nil)
      @logger = Calendly.configuration.logger
      @token = token || Calendly.configuration.token
      if @token.nil? || @token.to_s.empty?
        raise Calendly::Error, 'token is required.'
      end

      check_token
    end

    #
    # Get access token object
    #
    # @return [OAuth2::AccessToken]
    # @since 0.0.1
    def access_token
      return @access_token if defined?(@access_token)

      config = Calendly.configuration
      client = OAuth2::Client.new(config.client_id,
                                  config.client_secret, client_options)
      @access_token = OAuth2::AccessToken.new(
        client, @token,
        refresh_token: config.refresh_token,
        expires_at: config.token_expires_at
      )
    end

    #
    # Get basic information about current user
    #
    # @return [Calendly::User]
    # @since 0.0.1
    def current_user
      user
    end

    #
    # Get basic information about a user
    #
    # @param [String] uuid User unique identifier, or the constant "me" to reference the caller
    # @return [Calendly::User]
    # @since 0.0.1
    def user(uuid = 'me')
      body = request :get, "users/#{uuid}"
      User.new body[:resource]
    end

    #
    # Returns all Event Types associated with a specified User.
    #
    # @param [String] user_uri View event types available for the specified user (user URI).
    # @param [Hash] opts the optional request parameters.
    # @option opts [Integer] :count Number of rows to return.
    # @option opts [String] :page_token Pass this to get the next portion of collection.
    # @option opts [String] :sort  Order results by the specified field and direction. Accepts comma-separated list of {field}:{direction} values.
    # @return [Array<Array<Calendly::EventType>, Hash>]
    #  - [Array<Calendly::EventType>] event_types
    #  - [Hash] next_params the parameters to get next data. if thre is no next it returns nil.
    # @since 0.0.2
    def event_types(user_uri, opts = {})
      params = { user: user_uri }
      if opts.is_a? Hash
        opts.transform_keys!(&:to_sym)
        params.merge!(opts.slice(:count, :page_token, :sort))
      end
      body = request :get, 'event_types', params
      items = body[:collection] || []
      ev_types = items.map { |item| EventType.new item }
      [ev_types, next_page_params(body)]
    end

    private

    def request(method, path, params = {})
      @logger.debug "Request #{method.to_s.upcase} #{API_HOST}/#{path} params:#{params}"
      opts = { params: params }
      res = access_token.request(method, path, opts)
      @logger.debug "Response status:#{res.status}, body:#{res.body}"
      res.parsed
    rescue OAuth2::Error => e
      raise ApiError, e.response
    end

    def client_options
      faraday_build_proc = proc { |builder|
        builder.response(:json, parser_options: { symbolize_names: true },
                                content_type: /\bjson$/)
      }
      {
        site: API_HOST,
        authorize_url: "#{AUTH_API_HOST}/oauth/authorize",
        token_url: "#{AUTH_API_HOST}/oauth/token",
        connection_build: faraday_build_proc
      }
    end

    def check_token
      refresh! if access_token.expired?
    end

    def refresh!
      @access_token = access_token.refresh!
    end

    def next_page_params(body)
      return unless body[:pagination]
      return unless body[:pagination][:next_page]

      uri = URI.parse body[:pagination][:next_page]
      params = Hash[URI.decode_www_form(uri.query)]
      params.transform_keys(&:to_sym)
    end
  end
end
