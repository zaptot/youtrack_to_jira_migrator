# frozen_string_literal: true

module Youtrack::Entities
  class Link
    attr_reader :attrs, :parent_issue_id

    def initialize(attrs, issue_id)
      @parent_issue_id = issue_id
      @attrs = attrs.with_indifferent_access
    end

    def type
      attrs.dig(:linkType, :name)
    end

    def issue_from
      attrs.dig(:issue, :numberInProject)
    end

    def issues_to
      attrs[:issues].map { |issue| Issue.new(issue.merge(partial: true)) }
    end
  end
end
