# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'simplecov'
SimpleCov.start
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
require 'minitest/autorun'
require 'webmock/minitest'
require 'calendly'
require 'assert_helper'

require 'logger'
class MyLogger < Logger; end

module Calendly
  class BaseTest < Minitest::Test
    include AssertHelper

    HOST = Calendly::Client::API_HOST

    def setup
      @client_id = 'CLIENT_ID'
      @client_secret = 'CLIENT_SECRET'
      @token = 'TOKEN'
      @refresh_token = 'REFRESH_TOKEN'
      @expires_at = Time.now + 3600
      @expired_at = Time.now - 3600
      @my_logger = MyLogger.new STDOUT
      @my_logger.level = :info

      reset_configuration
      @client = Calendly::Client.new @token
    end

    def init_configuration(is_expired = false)
      Calendly.configure do |c|
        c.client_id = @client_id
        c.client_secret = @client_secret
        c.token = @token
        c.refresh_token = @refresh_token
        c.token_expires_at = is_expired ? @expired_at : @expires_at
        c.logger = @my_logger
      end
    end

    def reset_configuration
      Calendly.configure do |c|
        c.client_id = nil
        c.client_secret = nil
        c.token = nil
        c.refresh_token = nil
        c.token_expires_at = nil
        c.logger = @my_logger
      end
    end

    private

    def default_request_headers
      { 'Authorization' => "Bearer #{@token}" }
    end

    def default_response_headers
      {
        'Content-Type' => 'application/json; charset=utf-8'
      }
    end

    def load_test_data(filename)
      filepath = File.join File.dirname(__FILE__), 'testdata', filename
      File.new(filepath).read
    end

    def add_stub_request(method, url, req_headers: nil, req_body: nil, res_status: nil, res_headers: nil, res_body: nil)
      WebMock.enable!
      req_headers ||= default_request_headers
      res_headers ||= default_response_headers
      res_status ||= 200
      stub_request(method, url).with(body: req_body, headers: req_headers).to_return(status: res_status, body: res_body, headers: res_headers)
    end
  end
end
