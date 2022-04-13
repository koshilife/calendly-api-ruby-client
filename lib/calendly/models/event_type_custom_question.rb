# frozen_string_literal: true

module Calendly
  # Calendly's custom question model.
  class EventTypeCustomQuestion
    include ModelUtils

    # @return [String]
    # The custom question that the host created for the event type.
    attr_accessor :name

    # @return [String]
    # The type of response that the invitee provides to the custom question;
    # can be one or multiple lines of text, a phone number, or single- or multiple-select.
    attr_accessor :type

    # @return [Integer]
    # The numerical position of the question on the event booking page after the name and email address fields.
    attr_accessor :position

    # @return [Boolean]
    # true if the question created by the host is turned ON and visible on the event booking page;
    # false if turned OFF and invisible on the event booking page.
    attr_accessor :enabled

    # @return [Boolean]
    # true if a response to the question created by the host is required for invitees to book the event type;
    # false if not required.
    attr_accessor :required

    # @return [Array<String>]
    # The invitee’s option(s) for single_select or multi_select type of responses.
    attr_accessor :answer_choices

    # @return [Boolean]
    # true if the custom question lets invitees record a written response in addition to single-select or multiple-select type of responses;
    # false if it doesn’t.
    attr_accessor :include_other

  private

    def inspect_attributes
      super + %i[enabled position]
    end
  end
end
