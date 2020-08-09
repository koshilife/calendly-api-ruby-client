# frozen_string_literal: true

require 'test_helper'

class CalendlyClientTest < CalendlyBaseTest
  def test_that_it_has_a_version_number
    refute_nil ::Calendly::VERSION
  end

  #
  # test for Calendly::Client#current_user
  #

  def test_fetch_current_user
    user_res_body = load_test_data('user_001.json')
    add_stub_request(:get, "#{HOST}/users/me", res_body: user_res_body)
    user = @client.current_user
    assert_user001 user
  end

  #
  # test for Calendly::Client#user
  #

  def test_fetch_user
    user_res_body = load_test_data('user_001.json')
    add_stub_request(:get, "#{HOST}/users/U12345678", res_body: user_res_body)
    user = @client.user('U12345678')
    assert_user001 user
  end
end
