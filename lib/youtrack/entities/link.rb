# frozen_string_literal: true

module Youtrack::Entities
  class Link
    attr_reader :attrs

    def initialize(attrs)
      @attrs = attrs.with_indifferent_access
    end

    def type
      attrs.dig(:linkType, :name)
    end

    def issues
      attrs[:issues].map { |issue| Issue.new(issue.merge(partial: true)) }
    end
  end
end
