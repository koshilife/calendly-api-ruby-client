# frozen_string_literal: true

require 'test_helper'

module Calendly
  # test for Calendly::Team
  class TeamTest < BaseTest
    def setup
      super
      @team_uuid = 'T001'
      @team_uri = "#{HOST}/users/#{@team_uuid}"
      attrs = {uri: @team_uri}
      @team = Team.new attrs, @client
      @team_no_client = Team.new attrs
    end

    def test_it_returns_inspect_string
      assert @team.inspect.start_with? '#<Calendly::Team:'
    end
  end
end
