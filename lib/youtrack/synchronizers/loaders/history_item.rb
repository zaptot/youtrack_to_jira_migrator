# frozen_string_literal: true

module Youtrack::Synchronizers::Loaders::HistoryItem
  module_function

  def load(project_id, changes)
    IssueHistory.for_project(project_id).delete_all

    issues = issues(project_id)
    users = users(project_id)

    data_to_insert = changes.map do |change|
      next if change.string_value_from == change.string_value_to

      {
        field_name: change.field_name,
        field_type: change.field_type,
        from_string: change.string_value_from,
        to_string: change.string_value_to,
        created_at: change.created_at || Time.now,
        updated_at: Time.now,
        issue_id: issues[change.issue_number_in_project].id,
        jira_user_id: users[change.author.email].id,
        project_id: project_id
      }
    end.compact

    return if data_to_insert.blank?

    IssueHistory.insert_all(data_to_insert)
  end

  def users(project)
    JiraUser.for_project(project).group_by(&:email).transform_values(&:first)
  end

  def issues(project)
    Issue.for_project(project).group_by(&:number_in_project).transform_values(&:first)
  end
end
