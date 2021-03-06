# frozen_string_literal: true

module Youtrack::Synchronizers::Loaders::Attachment
  module_function

  def load(project_id, attachments)
    data_to_insert = attachments.map do |attachment|
      {
        comment_id: find_attachment_comment(project_id, attachment)&.id,
        issue_id: issues(project_id)[attachment.issue_number_in_project].id,
        name: attachment.name,
        url: attachment.url,
        project_id: project_id,
        created_at: Time.now,
        updated_at: Time.now
      }
    end

    return if data_to_insert.blank?

    Attachment.insert_all(data_to_insert, unique_by: %i[issue_id name])
  end

  def find_attachment_comment(project, attachment)
    return if attachment.comment.blank?

    Comment.find_by(jira_user: users(project)[attachment.comment.author.email],
                    issue: issues(project)[attachment.issue_number_in_project],
                    body: attachment.comment.body)
  end

  def issues(project)
    @issues ||= Issue.for_project(project).group_by(&:number_in_project).transform_values(&:first)
  end

  def users(project)
    @users ||= JiraUser.for_project(project).group_by(&:email).transform_values(&:first)
  end
end
