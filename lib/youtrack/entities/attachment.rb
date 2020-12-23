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
  end
end
