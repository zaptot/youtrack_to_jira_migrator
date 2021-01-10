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

    def created_at
      Time.at(attrs[:created].to_i / 1000)
    end

    def project_id
      attrs.dig(:project, :shortName)
    end

    def author
      User.new(attrs[:reporter])
    end

    def tags
      attrs[:tags].map { |tag| tag[:name] }
    end

    def resolved
      attrs[:resolved].present?
    end

    def attachments
      @attachments ||= attrs[:attachments].map { |attach| Attachment.new(attach) }
    end

    def links
      @links ||= attrs[:links].select { |link_type| link_type[:issues].any? }.map { |link| Link.new(link, id) }
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

    def json_custom_fields
      custom_fields.map do |field|
        custom_field = try(field)
        { type: custom_field.type, value: custom_field.value, field_name: custom_field.field_name }
      end
    end

    def respond_to_missing?(method_name, *args)
      custom_fields.include?(method_name) || super
    end
  end
end
