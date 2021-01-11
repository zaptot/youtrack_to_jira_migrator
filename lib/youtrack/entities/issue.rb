# frozen_string_literal: true

module Youtrack::Entities
  class Issue
    include Singleton

    attr_reader :attrs

    def init(attrs)
      @attrs = attrs
      self
    end

    def description
      attrs['description']
    end

    def title
      attrs['summary']
    end

    def id
      attrs['numberInProject']
    end

    def created_at
      Time.at(attrs['created'].to_i / 1000)
    end

    def project_id
      attrs.dig('project', 'shortName')
    end

    def author
      attrs['reporter']
    end

    def tags
      attrs['tags'].map { |tag| tag['name'] }
    end

    def resolved
      Time.at(attrs['resolved'].to_i / 1000) if attrs['resolved']
    end

    def voters
      attrs.dig('voters', 'original')
    end

    def watchers
      attrs.dig('watchers', 'issueWatchers').map do |issue_watcher|
        issue_watcher['user']
      end
    end

    def attachments
      attrs['attachments']
    end

    def links
      attrs['links'].select { |link_type| link_type['issues'].any? }
                    .map { |link| link.merge('parent_issue_id' => id) }
    end

    def comments
      attrs['comments'].reject { |comment| comment['deleted'] }
    end

    def method_missing(method_name, *args, &block)
      if custom_fields.include?(method_name.to_sym)
        attrs['customFields'].find { |field| field['name'].downcase.to_sym == method_name.to_sym }
      else
        super
      end
    end

    def custom_fields
      attrs['customFields'].map { |field| field['name'].downcase.to_sym }
    end

    def json_custom_fields
      custom_fields.map do |field|
        custom_field = attrs['customFields'].find { |_field| _field['name'].downcase.to_sym == field }
        custom_field = Youtrack::Entities::CustomField.instance.init(custom_field)
        { type: custom_field.type, value: custom_field.value, field_name: custom_field.field_name }
      end
    end

    def respond_to_missing?(method_name, *args)
      custom_fields.include?(method_name) || super
    end
  end
end
