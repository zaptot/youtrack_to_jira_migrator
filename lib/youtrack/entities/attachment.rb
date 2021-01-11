# frozen_string_literal: true

module Youtrack::Entities
  class Attachment
    include Singleton

    attr_reader :attrs

    def init(attrs)
      @attrs = attrs
      self
    end

    def url
      attrs['url']
    end

    def name
      attrs['name']
    end

    def comment
      attrs['comment'].presence
    end

    def issue_number_in_project
      attrs.dig('issue', 'numberInProject')
    end
  end
end
