# frozen_string_literal: true

require 'oauth2'

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
      res = request(:get, "users/#{uuid}")
      User.new_from_api(res)
    end

    private

    def request(method, path, params = {})
      @logger.debug "Request #{method.to_s.upcase} #{API_HOST}/#{path} params:#{params}"
      opts = { params: params }
      res = access_token.request(method, path, opts)
      @logger.debug "Response status:#{res.status}, body:#{res.body}"
      res
    rescue OAuth2::Error => e
      raise ApiError, e.response
    end

    def client_options
      {
        site: API_HOST,
        authorize_url: "#{AUTH_API_HOST}/oauth/authorize",
        token_url: "#{AUTH_API_HOST}/oauth/token"
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
