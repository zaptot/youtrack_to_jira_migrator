# frozen_string_literal: true

module Youtrack::Entities
  class User
    attr_reader :attrs

    def initialize(attrs)
      @attrs = attrs.with_indifferent_access
    end

    def email
      attrs[:email]
    end

    def full_name
      attrs[:login]
    end
  end
end
