# frozen_string_literal: true

class IssueSerializer < ActiveModel::Serializer
  attributes :description, :reporter, :assignee, :customFieldValues, :status, :key,
             :resolution, :watchers, :voters, fix_versions: :fixedVersions,
             title: :summary, tags: :labels, number_in_project: :externalId,
             created_at: :created, type: :issueType, estimate: :originalEstimate,
             resolved: :resolutionDate

  has_many :attachments
  has_many :comments
  has_many :worklogs

  CUSTOM_FIELDS_TYPE_MAPPINGS = {
    'SingleEnumIssueCustomField' => 'com.atlassian.jira.plugin.system.customfieldtypes:select',
    'SingleUserIssueCustomField' => 'com.atlassian.jira.plugin.system.customfieldtypes:userpicker',
    'SimpleIssueCustomField' => 'com.atlassian.jira.plugin.system.customfieldtypes:textfield',
    'PeriodIssueCustomField' => 'com.atlassian.jira.plugin.system.customfieldtypes:textfield',
    'SingleVersionIssueCustomField' => 'com.atlassian.jira.plugin.system.customfieldtypes:version',
    'DateIssueCustomField' => 'com.atlassian.jira.plugin.system.customfieldtypes:datepicker',
    'MultiUserIssueCustomField' => 'com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker',
    'SingleOwnedIssueCustomField' => 'com.atlassian.jira.plugin.system.customfieldtypes:select'
  }.freeze
  DEFAULT_JIRA_TYPE = 'com.atlassian.jira.plugin.system.customfieldtypes:textfield'

  def key
    "#{object.project_id}-#{object.number_in_project}"
  end

  def reporter
    object.jira_user.full_name
  end

  def resolution
    object.resolved.present? ? 'Resolved' : 'Unresolved'
  end

  def description
    SyntaxMigrator.migrate_text_to_jira_syntax(object.description, object.project_id)
  end

  def customFieldValues
    object.custom_fields_without_system.map do |field|
      value = transform_custom_field_value(field)
      type = transform_custom_field_type(field['type'], value)

      {
        fieldName: field['field_name'],
        fieldType: type,
        value: value
      }
    end
  end

  private

  def transform_custom_field_value(field)
    case field['type']
    when 'DateIssueCustomField'
      Time.at(field['value'] / 1000).strftime('%d/%b/%y')
    when 'PeriodIssueCustomField'
      "PT#{field['value']}M"
    else
      field['value']
    end
  end

  def transform_custom_field_type(type, value)
    if type == 'SimpleIssueCustomField' && (value.is_a?(Float) || value.is_a?(Integer))
      'com.atlassian.jira.plugin.system.customfieldtypes:float'
    else
      CUSTOM_FIELDS_TYPE_MAPPINGS[type] || DEFAULT_JIRA_TYPE
    end
  end
end
