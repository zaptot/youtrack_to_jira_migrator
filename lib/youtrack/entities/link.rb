# frozen_string_literal: true

module Youtrack::Entities
  class Link
    include Singleton

    attr_reader :attrs

    def init(attrs)
      @attrs = attrs
      self
    end

    def type
      attrs.dig('linkType', 'name')
    end

    def issue_from
      attrs.dig('issue', 'numberInProject')
    end

    def issues_to
      attrs['issues']
    end

    def direction
      attrs['direction']
    end

    def parent_issue_id
      attrs['parent_issue_id']
    end
  end
end
