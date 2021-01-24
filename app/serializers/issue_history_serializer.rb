# frozen_string_literal: true

class IssueHistorySerializer < ActiveModel::Serializer
  attributes :author, :items, created_at: :created

  def author
    object.jira_user.full_name
  end

  def items
    [
      {
        fieldType: object.field_type,
        field: object.field_name,
        fromString: transform_value(object.from_string),
        toString: transform_value(object.to_string)
      }
    ]
  end

  private

  def transform_value(value)
    value = SyntaxMigrator.migrate_text_to_jira_syntax(value, object.project_id)
    SyntaxMigrator.normalized_history_values(object.field_name, value)
  end
end
