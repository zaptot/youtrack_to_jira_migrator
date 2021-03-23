# frozen_string_literal: true

module Youtrack::Synchronizers::Loaders::Link
  module_function

  def load(project_id, links)
    data_to_insert = []
    available_projects = Project.pluck(:id)
    issues = {}

    links.uniq(&:attrs).each do |link|
      link.issues_to.each do |issue_to|
        next unless available_projects.include?(issue_to.project_id)
        next unless issues(issues, issue_to.project_id)[issue_to.id].present?

        issue_from, issue_to = calculate_issues_order(link, issue_to, link.parent_issue_id, project_id)

        data_to_insert << {
          type: link.type,
          issue_from_id: issues(issues, issue_from.project_id)[issue_from.id].id,
          issue_to_id: issues(issues, issue_to.project_id)[issue_to.id].id,
          created_at: Time.now,
          updated_at: Time.now,
          project_from_id: issue_from.project_id,
          project_to_id: issue_to.project_id
        }
      end
    end

    return if data_to_insert.blank?

    Link.insert_all(data_to_insert, unique_by: %i[type issue_from_id issue_to_id])
  end

  def issues(issues, project)
    issues[project] ||= Issue.for_project(project).group_by(&:number_in_project).transform_values(&:first)
  end

  def calculate_issues_order(link, issue_to, parent_issue_id, parent_project_id)
    case link.direction
    when 'INWARD'
      [issue_to, Issue.new(id: parent_issue_id, project_id: parent_project_id)]
    when 'OUTWARD'
      [Issue.new(id: parent_issue_id, project_id: parent_project_id), issue_to]
    else
      [issue_to, Issue.new(id: parent_issue_id, project_id: parent_project_id)].sort_by(&:id)
    end
  end
end
