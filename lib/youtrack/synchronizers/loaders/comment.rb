# frozen_string_literal: true

module Youtrack::Synchronizers::Loaders::Comment
  module_function

  def load(project_id, comments)
    data_to_insert = comments.map do |comment|
      comment = Youtrack::Entities::Comment.instance.init(comment)
      author = Youtrack::Entities::User.instance.init(comment.author)

      {
        body: comment.body,
        created_at: comment.created_at || Time.now,
        updated_at: Time.now,
        issue_id: issues(project_id)[comment.issue_number_in_project].id,
        jira_user_id: users(project_id)[author.email].id,
        project_id: project_id
      }
    end

    return if data_to_insert.blank?

    Comment.insert_all(data_to_insert, unique_by: [:project_id, :issue_id, :jira_user_id, :created_at])
  end

  def users(project)
    @users ||= JiraUser.for_project(project).group_by(&:email).transform_values(&:first)
  end

  def issues(project)
    @issues ||= Issue.for_project(project).group_by(&:number_in_project).transform_values(&:first)
  end
end
