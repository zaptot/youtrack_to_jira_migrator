# frozen_string_literal: true

module Youtrack::Synchronizer::Comment
  module_function

  def sync(project_id, comments)
    data_to_insert = comments.map do |comment|
      {
        body: comment.body,
        state: :new,
        created_at: comment.created_at || Time.now,
        updated_at: Time.now,
        issue_id: issues(project_id)[comment.issue_number_in_project].id,
        jira_user_id: users(project_id)[comment.author_email].id
      }
    end

    return if data_to_insert.blank?

    Comment.insert_all(data_to_insert)
  end

  def users(project)
    @users ||= JiraUser.for_project(project).group_by(&:email).transform_values(&:first)
  end

  def issues(project)
    @issues ||= Issue.for_project(project).group_by(&:number_in_project).transform_values(&:first)
  end
end
