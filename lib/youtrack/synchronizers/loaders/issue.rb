# frozen_string_literal: true

module Youtrack::Synchronizers::Loaders::Issue
  module_function

  def load(project_id, issues)
    users = users(project_id)

    data_to_insert = issues.map do |issue|
      {
        number_in_project: issue.id,
        voters: issue.voters.map { |user| user.full_name },
        watchers: issue.watchers.map { |user| user.full_name },
        resolved: issue.resolved,
        title: issue.title,
        description: issue.description,
        custom_fields: issue.json_custom_fields.select { |field| field[:value].present? },
        jira_user_id: users[issue.author.email].id,
        project_id: project_id,
        tags: issue.tags,
        created_at: issue.created_at || Time.now,
        updated_at: Time.now
      }
    end

    return if data_to_insert.blank?

    Issue.insert_all(data_to_insert, unique_by: [:project_id, :number_in_project])
  end

  def users(project)
    JiraUser.for_project(project).group_by(&:email).transform_values(&:first)
  end
end
