# frozen_string_literal: true

module Youtrack::Synchronizers::Loaders::Worklog
  module_function

  def load(project_id, worklogs)
    Worklog.for_project(project_id).delete_all

    data_to_insert = worklogs.map do |worklog|
      worklog = Youtrack::Entities::Worklog.instance.init(worklog, project_id)
      author = Youtrack::Entities::User.instance.init(worklog.author)

      {
        text: worklog.text,
        date: worklog.date,
        duration: worklog.duration,
        created_at: worklog.created_at || Time.now,
        updated_at: Time.now,
        issue_id: issues(project_id)[worklog.issue_number_in_project].id,
        jira_user_id: users(project_id)[author.email].id,
        project_id: project_id
      }
    end

    return if data_to_insert.blank?

    Worklog.insert_all(data_to_insert)
  end

  def users(project)
    @users ||= JiraUser.for_project(project).group_by(&:email).transform_values(&:first)
  end

  def issues(project)
    @issues ||= Issue.for_project(project).group_by(&:number_in_project).transform_values(&:first)
  end
end
