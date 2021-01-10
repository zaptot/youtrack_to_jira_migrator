# frozen_string_literal: true

class IssueSerializer < ActiveModel::Serializer
  attributes :description, :reporter, :assignee, :customFieldValues, :status, :key, :resolution,
             title: :summary, tags: :labels, number_in_project: :externalId,
             created_at: :created, type: :issueType, estimate: :originalEstimate,
             fix_versions: :fixedVersions

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
    object.resolved? ? 'Resolved' : 'Unresolved'
  end

  def description
    SyntaxMigrator.migrate_text_to_jira_syntax(object.description, object.project_id)
  end

  def customFieldValues
    object.custom_fields_without_system.map do |field|
      {
        fieldName: field['field_name'],
        fieldType: CUSTOM_FIELDS_TYPE_MAPPINGS[field['type']] || DEFAULT_JIRA_TYPE,
        value: transform_custom_field_value(field)
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
end
