# frozen_string_literal: true

class WorklogSerializer < ActiveModel::Serializer
  attributes :author, :comment, date: :startDate, duration_period: :timeSpent

  def author
    object.jira_user.full_name
  end

  def comment
    SyntaxMigrator.migrate_text_to_jira_syntax(object.text, object.project)
  end
end
