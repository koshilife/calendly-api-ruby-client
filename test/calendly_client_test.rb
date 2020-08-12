# frozen_string_literal: true

require 'test_helper'

class CalendlyClientTest < CalendlyBaseTest
  def test_that_it_has_a_version_number
    refute_nil ::Calendly::VERSION
  end

  #
  # test for current_user
  #

  def test_that_it_is_returned_a_current_user
    res_body = load_test_data 'user_001.json'
    add_stub_request :get, "#{HOST}/users/me", res_body: res_body

    user = @client.current_user
    assert_user001 user
  end

  #
  # test for user
  #

  def test_that_it_is_returned_a_specific_user
    res_body = load_test_data 'user_001.json'
    add_stub_request :get, "#{HOST}/users/U12345678", res_body: res_body

    user = @client.user 'U12345678'
    assert_user001 user
  end

  #
  # test for event_types
  #

  def test_that_it_is_returned_all_items_of_event_type
    res_body = load_test_data 'event_types_001.json'
    user_uri = 'https://api.calendly.com/users/U12345678'
    params = { user: user_uri }

    url = "#{HOST}/event_types?#{URI.encode_www_form(params)}"
    add_stub_request(:get, url, res_body: res_body)

    event_types, next_params = @client.event_types user_uri
    assert_equal 3, event_types.length
    assert_nil next_params
    assert_event_type001 event_types[0]
    assert_event_type002 event_types[1]
    assert_event_type003 event_types[2]
  end

  def test_that_it_is_returned_all_items_of_event_type_by_pagination
    user_uri = 'https://api.calendly.com/users/U12345678'

    res_body1 = load_test_data 'event_types_002_page1.json'
    option_params1 = { count: 2, sort: 'created_at:desc' }
    params1 = { user: user_uri }.merge option_params1
    url1 = "#{HOST}/event_types?#{URI.encode_www_form(params1)}"
    add_stub_request(:get, url1, res_body: res_body1)

    res_body2 = load_test_data 'event_types_002_page2.json'
    option_params2 = { count: 2, page_token: 'NEXT_PAGE_TOKEN' }
    params2 = { user: user_uri }.merge option_params2
    url2 = "#{HOST}/event_types?#{URI.encode_www_form(params2)}"
    add_stub_request(:get, url2, res_body: res_body2)

    # request page1
    event_types_page1, next_params_page1 = @client.event_types user_uri, option_params1
    user_uri_page1 = next_params_page1.delete(:user)
    # request page2
    event_types_page2, next_params2 = @client.event_types user_uri_page1, next_params_page1

    assert_equal 2, event_types_page1.length
    assert_equal 1, event_types_page2.length
    assert_nil next_params2
    assert_event_type003 event_types_page1[0]
    assert_event_type002 event_types_page1[1]
    assert_event_type001 event_types_page2[0]
  end
end
