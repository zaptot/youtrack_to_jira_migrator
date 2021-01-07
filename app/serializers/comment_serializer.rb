# frozen_string_literal: true

class CommentSerializer < ActiveModel::Serializer
  attributes :body, :author, created_at: :created

  def author
    object.jira_user.full_name
  end

  def body
    SyntaxMigrator.migrate_text_to_jira_syntax(object.body, object.project_id, object.attachments.pluck(:name))
  end
end
