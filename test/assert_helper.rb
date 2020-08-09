# frozen_string_literal: true

require 'time'

module AssertHelper
  def assert_user001(user)
    assert_equal 'U12345678', user.uuid
    assert_equal 'https://api.calendly.com/users/U12345678', user.uri
    assert_equal 'FooBar', user.name
    assert_equal 'foobar', user.slug
    assert_equal 'foobar@example.com', user.email
    assert_equal 'https://foobar.cloudfront.net/uploads/user/avatar/foobar/foobar.gif', user.avatar_url
    assert_equal 'https://calendly.com/foobar', user.scheduling_url
    assert_equal 'Asia/Tokyo', user.timezone
    assert_equal Time.parse('2020-05-01T00:00:00.000Z').to_i, user.created_at.to_i
    assert_equal Time.parse('2020-05-02T00:00:00.000Z').to_i, user.updated_at.to_i
  end
end
