# frozen_string_literal: true

module Youtrack::Entities
  class Issue
    attr_reader :attrs

    def initialize(attrs)
      @attrs = attrs.with_indifferent_access
    end

    def description
      attrs[:description]
    end

    def title
      attrs[:summary]
    end

    def id
      attrs[:numberInProject]
    end

    def project_id
      attrs.dig(:project, :shortName)
    end

    def author_email
      attrs.dig(:reporter, :email)
    end

    def tags
      attrs[:tags]&.map { |tag| tag[:name] }
    end

    def attachments
      @attachments ||= attrs[:attachments]&.map { |attach| Attachment.new(attach) }
    end

    def links
      @links ||= attrs[:links].select { |link_type| link_type[:issues].any? }.map { |link| Link.new(link) }
    end

    def comments
      @comments ||= attrs[:comments].reject { |comment| comment[:deleted] }.map { |comment| Comment.new(comment) }
    end

    def method_missing(method_name, *args, &block)
      if custom_fields.include?(method_name.to_sym)
        CustomField.new(attrs[:customFields].find { |field| field[:name].downcase.to_sym == method_name.to_sym })
      else
        super
      end
    end

    def custom_fields
      @custom_fields ||= attrs[:customFields].map { |field| field[:name].downcase.to_sym }
    end

    def respond_to_missing?(method_name, *args)
      custom_fields.include?(method_name) || super
    end
  end
end
