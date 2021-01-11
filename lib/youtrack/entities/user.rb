# frozen_string_literal: true

module Youtrack::Entities
  class User
    include Singleton

    attr_reader :attrs

    def init(attrs)
      @attrs = attrs
      self
    end

    def email
      attrs['email'] || attrs['login']
    end

    def full_name
      attrs['login'] || attrs['email']
    end
  end
end
