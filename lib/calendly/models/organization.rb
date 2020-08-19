# frozen_string_literal: true

module Calendly
  class Organization
    include ModelUtils
    API_URL = "#{Client::API_HOST}/organization/"
    TIME_FIELDS = %i[created_at updated_at].freeze
  end
end
