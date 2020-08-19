# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'simplecov'
SimpleCov.start
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!
require 'webmock/minitest'

require 'calendly'
require 'assert_helper'

class CalendlyBaseTest < Minitest::Test
  include AssertHelper

  HOST = Calendly::Client::API_HOST

  def setup
    @client = Calendly::Client.new('token')
  end

  private

  def default_request_headers(token = 'token')
    { 'Authorization' => "Bearer #{token}" }
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

  def add_stub_request(method, url, req_body: nil, req_headers: nil, res_status: nil, res_body: nil, res_headers: nil)
    WebMock.enable!
    req_headers ||= default_request_headers
    res_headers ||= default_response_headers
    res_status ||= 200
    stub_request(method, url).with(body: req_body, headers: req_headers).to_return(status: res_status, body: res_body, headers: res_headers)
  end
end
