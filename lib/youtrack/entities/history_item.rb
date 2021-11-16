# frozen_string_literal: true

module Youtrack::Entities
  class HistoryItem
    attr_reader :attrs

    JIRA_SYSTEM_FIELDS = %w[fixedVersions issueType originalEstimate description summary status].freeze

    def initialize(attrs, project_id)
      @project_id = project_id
      @attrs = attrs.with_indifferent_access
    end

    def author
      User.new(attrs[:author])
    end

    def created_at
      Time.at(attrs[:timestamp].to_i / 1000)
    end

    def issue_number_in_project
      attrs.dig(:target, :numberInProject)
    end

    def field_name
      transform_fields_names_for_jira(attrs.dig(:field, :name))
    end

    def field_type
      if field_name.in?(JIRA_SYSTEM_FIELDS)
        'jira'
      else
        'custom'
      end
    end

    def string_value_from
      value_to_string(attrs[:removed])
    end

    def string_value_to
      value_to_string(attrs[:added])
    end

    private

    def transform_fields_names_for_jira(field_name)
      case field_name
      when 'Fix versions' then 'fixedVersions'
      when 'Type' then 'issueType'
      when 'Estimate' then 'originalEstimate'
      when status_field then 'status'
      else
        field_name.downcase
      end
    end

    def status_field
      Project.find(@project_id).status_field
    end

    def value_to_string(value)
      case value
      when Array
        value.first&.dig(:name).to_s
      else
        value.to_s
      end
    end
  end
end
