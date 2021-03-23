# frozen_string_literal: true

module Youtrack::Synchronizers::Loaders::Worklog
  module_function

  def load(project_id, worklogs)
    Worklog.for_project(project_id).delete_all

    issues = issues(project_id)
    users = users(project_id)

    data_to_insert = worklogs.map do |worklog|
      {
        text: worklog.text,
        date: worklog.date,
        duration: worklog.duration,
        created_at: worklog.created_at || Time.now,
        updated_at: Time.now,
        issue_id: issues[worklog.issue_number_in_project].id,
        jira_user_id: users[worklog.author.email].id,
        project_id: project_id
      }
    end

    return if data_to_insert.blank?

    Worklog.insert_all(data_to_insert)
  end

  def users(project)
    JiraUser.for_project(project).group_by(&:email).transform_values(&:first)
  end

  def issues(project)
    Issue.for_project(project).group_by(&:number_in_project).transform_values(&:first)
  end
end
