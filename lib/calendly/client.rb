# frozen_string_literal: true

require 'oauth2'
require 'faraday_middleware'

module Calendly
  # Calendly apis client.
  class Client
    API_HOST = 'https://api.calendly.com'
    AUTH_API_HOST = 'https://auth.calendly.com'

    # @param token [String] a Calendly's access token.
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
    #
    def access_token
      return @access_token if defined?(@access_token)

      config = Calendly.configuration
      client = OAuth2::Client.new(
        config.client_id,
        config.client_secret,
        client_options
      )
      @access_token = OAuth2::AccessToken.new(
        client,
        @token,
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
    # @param uuid [String] User unique identifier, or the constant "me" to reference the caller
    # @return [Calendly::User]
    # @since 0.0.1
    def user(uuid = 'me')
      body = request :get, "users/#{uuid}"
      User.new body[:resource]
    end

    #
    # Returns all Event Types associated with a specified User.
    # GET https://api.calendly.com/event_types
    #
    # @param user_uri [String] View event types available for the specified user (user URI).
    # @param options [Hash] the optional request parameters
    # @param options :count [String] Number of rows to return.
    # @param options :page_token [String] Pass this to get the next portion of collection.
    # @param options :sort [String] Order results by the specified field and direction. Accepts comma-separated list of {field}:{direction} values.
    # @return [event_types, next_params]
    #  - event_types [Array<Calendly::EventType>]
    #  - next_params [Hash]
    #
    # @since 0.0.2
    def event_types(user_uri, options = {})
      params = { user: user_uri }
      if options.is_a? Hash
        options.transform_keys!(&:to_sym)
        params.merge!(sort: options[:sort]) if options[:sort]
        params.merge!(count: options[:count]) if options[:count]
        params.merge!(page_token: options[:page_token]) if options[:page_token]
      end
      body = request :get, 'event_types', params
      items = body[:collection] || []
      ev_types = items.map { |item| EventType.new item }
      if body[:pagination][:next_page]
        next_page_query = URI.parse(body[:pagination][:next_page]).query
        next_page_params = Hash[URI.decode_www_form(next_page_query)]
        next_page_params.transform_keys!(&:to_sym)
      end
      [ev_types, next_page_params]
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
        builder.response(
          :json,
          parser_options: { symbolize_names: true },
          content_type: /\bjson$/
        )
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
  end
end
