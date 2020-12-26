# frozen_string_literal: true

module Youtrack::Entities
  class Attachment
    attr_reader :attrs

    def initialize(attrs)
      @attrs = attrs.with_indifferent_access
    end

    def url
      attrs[:url]
    end

    def name
      attrs[:name]
    end

    def comment
      Comment.new(attrs[:comment]) if attrs[:comment].present?
    end

    def issue_number_in_project
      attrs.dig(:issue, :numberInProject)
    end
  end
end
