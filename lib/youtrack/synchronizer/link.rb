# frozen_string_literal: true

module Youtrack::Synchronizer::Link
  module_function

  def sync(project_id, links)
    data_to_insert = []
    links.each do |link|
      link.issues_to.each do |issue_to|
        # TODO: add logs of unsaved links or system for resync them ??
        next unless available_projects.include?(issue_to.project_id)
        next unless issues(issue_to.project_id)[issue_to.id].present?

        issue_from_id, issue_to_id = calculate_issues_order(link, issue_to.id, link.parent_issue_id)

        data_to_insert << {
          type: link.type,
          issue_from_id: issues(project_id)[issue_from_id].id,
          issue_to_id: issues(issue_to.project_id)[issue_to_id].id,
          state: :new,
          created_at: Time.now,
          updated_at: Time.now,
          project_id: project_id
        }
      end
    end

    return if data_to_insert.blank?

    Link.insert_all(data_to_insert, unique_by: %i[type issue_from_id issue_to_id])
  end

  def issues(project)
    @issues ||= {}
    @issues[project] ||= Issue.for_project(project).group_by(&:number_in_project).transform_values(&:first)
  end

  def available_projects
    @available_projects ||= Project.pluck(:id)
  end

  def calculate_issues_order(link, issue_to_id, parent_issue_id)
    case link.direction
    when 'INWARD'
      [issue_to_id, parent_issue_id]
    when 'OUTWARD'
      [parent_issue_id, issue_to_id]
    else
      [issue_to_id, parent_issue_id].sort
    end
  end
end
