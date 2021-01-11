# frozen_string_literal: true

module Youtrack::Entities
  class CustomField
    include Singleton

    attr_reader :attrs

    def init(attrs)
      @attrs = attrs
      self
    end

    def value
      if attrs.dig('value').is_a?(Array)
        attrs.dig('value').map { |value| value&.values_at('email', 'minutes', 'name')&.compact&.first }
      elsif attrs.dig('value').is_a?(String) || attrs.dig('value').blank? || attrs.dig('value').is_a?(Integer)
        attrs.dig('value')
      elsif attrs.dig('value').is_a?(Hash)
        attrs.dig('value')&.values_at('login', 'minutes', 'name')&.compact&.first
      else
        raise ArgumentError, 'unknown custom field value type'
      end
    end

    def type
      attrs['$type']
    end

    def field_name
      attrs['name']
    end

    def user
      if attrs.dig('value').is_a?(Hash) && attrs['value'].values_at('login', 'email').compact.any?
        attrs['value']
      end
    end
  end
end
