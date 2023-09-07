# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::Team
  class TeamTest < BaseTest
    def setup
      super
      @team_uuid = 'T001'
      @team_uri = "#{HOST}/teams/#{@team_uuid}"
      attrs = {uri: @team_uri}
      @team = Team.new attrs, @client
    end

    def test_it_returns_inspect_string
      assert @team.inspect.start_with? '#<Calendly::Team:'
    end

    def test_that_it_parses_uuid_be_formatted_ascii_from_uri
      uuid = '4b0b25ba-2078-409a-ba27-a419c257c811'
      uri = "#{HOST}/teams/#{uuid}"
      assert_equal(uuid, Team.extract_uuid(uri))
    end
  end
end
