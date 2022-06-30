# frozen_string_literal: true

class IssueSerializer < ActiveModel::Serializer
  attributes :description, :reporter, :assignee, :priority, :customFieldValues, :status, :key,
             :resolution, :watchers, :voters, :history, fix_versions: :fixedVersions,
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
    'SingleOwnedIssueCustomField' => 'com.atlassian.jira.plugin.system.customfieldtypes:select',
    'TextIssueCustomField' => 'com.atlassian.jira.plugin.system.customfieldtypes:textarea'
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
    SyntaxMigrator.migrate_text_to_jira_syntax(object.description, object.project)
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

  def history
    ActiveModel::ArraySerializer.new(
      object.issue_histories,
      each_serializer: IssueHistorySerializer
    ).serializable_array
  end

  private

  def transform_custom_field_value(field)
    case field['type']
    when 'DateIssueCustomField'
      Time.at(field['value'] / 1000).strftime('%d/%b/%y')
    when 'PeriodIssueCustomField'
      "PT#{field['value']}M"
    when 'MultiUserIssueCustomField'
      field['value'].map { |e| e.gsub(/@.+/, '') }
    when 'TextIssueCustomField'
      SyntaxMigrator.migrate_text_to_jira_syntax(field['value'], object.project)
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
