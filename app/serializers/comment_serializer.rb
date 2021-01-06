# frozen_string_literal: true

class CommentSerializer < ActiveModel::Serializer
  attributes :body, :author, created_at: :created

  def author
    object.jira_user.full_name
  end
end
