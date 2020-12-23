# frozen_string_literal: true

module Youtrack::Entities::Issue
  class CustomField
    attr_reader :attrs

    def initialize(attrs)
      @attrs = attrs.with_indifferent_access
    end

    def value
      attrs.dig(:value, :name)
    end

    def type
      attrs[:$type]
    end

    def field_name
      attrs[:name]
    end
  end
end
